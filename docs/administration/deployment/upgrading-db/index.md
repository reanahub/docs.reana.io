# Upgrading database

If you are the REANA cluster administrator upgrading an existing REANA
cluster deployment from one REANA release series to another, such as
from 0.7.\* to 0.8.0, there might be changes to either the REANA database schema and/or to the PostgreSQL version.

In the following sections, we will first explain how to migrate REANA to a new major version of PostgreSQL, and then we will show how to upgrade the database schema.

## Upgrading PostgreSQL to a new major version

PostgreSQL version numbers always consist in a major and in a minor number.
Considering as an example PostgreSQL 14.6, 14 is the major version number and 6 is the minor one.
Minor releases are always compatible with earlier minor releases, so nothing needs to be done in this case.
However, when updating to a new major release, the database needs to be dumped from the older version and then restored in the new one.

Note that you need to follow these instructions **only** if:

- you are using the internal PostgreSQL database provided by the REANA Helm chart, and
- you are upgrading to a version of REANA that provides a new major version of PostgreSQL (e.g. going from PostgreSQL version 12.13 to 14.6)

!!! danger
    This procedure is delicate and it can lead to data loss. Carefully read the following instructions and, if possible, try them out on a test instance of REANA to make sure that everything works.

!!! note
    This guide requires to upgrade REANA a few times by using the `helm` tool. To make sure that you are running the correct commands, you can use the [`helm-diff`](https://github.com/databus23/helm-diff) plugin to inspect the changes that will be made to REANA's deployment.

Let us consider upgrading a REANA cluster from version `$OLD_VERSION` to `$NEW_VERSION`:

1. First of all, disable the scheduling of new workflows by setting `REANA_MAX_CONCURRENT_BATCH_WORKFLOWS` to zero:

    ```{ .console .copy-to-clipboard }
    $ helm upgrade reana reanahub/reana \
        --version $OLD_VERSION \
        --values myvalues.yaml \
        --set components.reana_server.environment.REANA_MAX_CONCURRENT_BATCH_WORKFLOWS=0
    ```

2. Wait for all the running workflows to finish. You can run `kubectl get pods` to make sure that workflows are not running.
3. Create a full dump of the database:

    ```{ .console .copy-to-clipboard }
    $ kubectl exec deployment/reana-db -- pg_dump -U reana reana > db.dump
    ```

    You can also compress the dump to consume less disk space:

    ```{ .console .copy-to-clipboard }
    $ kubectl exec deployment/reana-db -- pg_dump -U reana reana | gzip > db.dump.gz
    ```

    Note that the dump is guaranteed to be consistent, but new data that is added to the database after creating the dump will be lost.

4. Update to the new version of REANA, while entering maintenance mode at the same time:

    ```{ .console .copy-to-clipboard }
    $ helm upgrade reana reanahub/reana \
        --version $NEW_VERSION \
        --values myvalues.yaml \
        --set components.reana_server.environment.REANA_MAX_CONCURRENT_BATCH_WORKFLOWS=0 \
        --set maintenance.enabled=true
    ```

5. You should now move the database directory inside the REANA storage volume to a new location, so that the default one can be used to initialise a new empty database. To do so, you can open a shell in a new pod:

    ??? "reana-maintenance.yaml"

        Note that, depending on how REANA is configured, you will need to mount the correct volume to be able to access the database directory.

        ```{ .yaml .copy-to-clipboard }
        apiVersion: v1
        kind: Pod
        metadata:
          name: reana-maintenance
        spec:
          containers:
            - name: reana-maintenance
              image: ubuntu:20.04
              command:
                - sleep
              args:
                - infinity
              volumeMounts:
                - name: reana-storage
                  mountPath: "/var/reana"
          restartPolicy: Never
          volumes:
            - name: reana-storage
              persistentVolumeClaim:
                claimName: reana-shared-persistent-volume
              # hostPath:
              #   path: "/var/reana"
              # persistentVolumeClaim:
              #   claimName: reana-infrastructure-persistent-volume
        ```

    ```console
    $ kubectl apply -f reana-maintenance.yaml
    $ kubectl exec -it pod/reana-maintenance -- bash
    root@reana-maintenance:/# cd /var/reana
    root@reana-maintenance:/var/reana# ls
    config  db  rabbitmq  users  uwsgi
    root@reana-maintenance:/var/reana# mv db db_bak
    root@reana-maintenance:/var/reana# exit
    ```

    The new database directory `db_bak` can also be used to restore the original database in case the update fails.

6. Scale up the database deployment, as this will automatically initialise a new empty database:

    ```{ .console .copy-to-clipboard }
    $ kubectl scale --replicas 1 deployment/reana-db
    ```

7. You can now import the dump in the newly created database:

    ```{ .console .copy-to-clipboard }
    $ kubectl exec -i deployment/reana-db -- psql --single-transaction -U reana reana < db.dump
    ```

    If you opted for compressing your database dump, then you should uncompress it before passing it to `psql`:

    ```{ .console .copy-to-clipboard }
    $ gunzip -c db.dump.gz | kubectl exec -i deployment/reana-db -- psql --single-transaction -U reana reana
    ```

8. Exit maintenance mode and re-enable the submission of workflows:

    ```{ .console .copy-to-clipboard }
    $ helm upgrade reana reanahub/reana \
        --version $NEW_VERSION \
        --values myvalues.yaml
    ```

9. If needed, upgrade the database schema as explained in [Upgrading the database schema](#upgrading-the-database-schema).

10. If everything went well, you can then delete the old database directory `db_bak` by connecting again to `reana-maintenance`:

    ```console
    $ kubectl exec -it pod/reana-maintenance -- bash
    root@reana-maintenance:/# cd /var/reana
    root@reana-maintenance:/var/reana# ls
    config  db  db_bak rabbitmq  users  uwsgi
    root@reana-maintenance:/var/reana# rm -rf db_bak
    root@reana-maintenance:/var/reana# exit
    $ kubectl delete pod/reana-maintenance
    ```

## Upgrading the database schema

In case of database schema changes, it is necessary to run a
database upgrade script using [`alembic`](https://alembic.sqlalchemy.org/en/latest/).

The `reana-db` command-line tool is provided to ease the database
upgrade tasks. The tool is included in the `REANA-Server` component.

Two different procedures will be explained. The first, covers a quick
database upgrade after a successful cluster upgrade. The second, covers
a more detailed upgrade procedure, in case you want to have a better
control or you need to troubleshoot some unexpected issues during the
upgrade.

### Quick upgrade procedure

After you upgrade REANA by running `helm upgrade` successfully, run the
following command:

```{ .console .copy-to-clipboard }
$ kubectl exec -i -t deployment/reana-server -c rest-api -- reana-db alembic upgrade
```

The output will show the accomplished upgrades, for example:

```console
$ kubectl default exec -i -t deployment/reana-server -c rest-api -- reana-db alembic upgrade
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade  -> c912d4f1e1cc, Quota tables.
INFO  [alembic.runtime.migration] Running upgrade c912d4f1e1cc -> ad93dae04483, Interactive sessions.
INFO  [alembic.runtime.migration] Running upgrade ad93dae04483 -> 4801b98f6408, Job started and finished times.
INFO  [alembic.runtime.migration] Running upgrade 4801b98f6408 -> f84e17bd6b18, Workflow complexity.
INFO  [alembic.runtime.migration] Running upgrade f84e17bd6b18 -> 6568d7cb6710, storing full workflow workspace.
```

At this point, the upgrade of the database finished successfully and the
procedure is done.

### Detailed upgrade procedure

First, you can check all the alembic `history` to list all the
existing revisions:

```console
$ kubectl exec -i -t deployment/reana-server -c rest-api -- reana-db alembic history
f84e17bd6b18 -> 6568d7cb6710 (head), storing full workflow workspace.
4801b98f6408 -> f84e17bd6b18, Workflow complexity.
ad93dae04483 -> 4801b98f6408, Job started and finished times.
c912d4f1e1cc -> ad93dae04483, Interactive sessions.
<base> -> c912d4f1e1cc, Quota tables.
```

And also, get the exact hash of your `current` revision:

```console
$ kubectl exec -i -t deployment/reana-server -c rest-api -- reana-db alembic current
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
4801b98f6408
```

In this particular example, the current revision hash is `4801b98f6408`
which corresponds to `Job started and finished times.`

As used in the previous section, the `upgrade` command without any
additional argument will attempt to upgrade the database to the latest
revision (`head`). But it is also possible to pass a revision hash in
the event that you want to upgrade to a certain revision.

Let us upgrade to the next revision (`Workflow complexity.`) by passing
its revision hash (`f84e17bd6b18`) to test the database schema changes
introduced there:

```console
$ kubectl exec -i -t deployment/reana-server -c rest-api -- reana-db alembic upgrade f84e17bd6b18
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade 4801b98f6408 -> f84e17bd6b18, Workflow complexity.
```

In some exceptional cases you might need to `downgrade` to a previous
revision. For example, due to a failure during the release upgrade
process, or because you were testing an alpha version and you want to
revert to the previous state. To do this, you need to specify the exact
hash of the revision you want to downgrade to. The following example
shows a command to downgrade the database schema to the previous
revision:

```console
$ kubectl exec -i -t deployment/reana-server -c rest-api -- reana-db alembic downgrade 4801b98f6408
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running downgrade f84e17bd6b18 -> 4801b98f6408, Workflow complexity.
```

If you run again the `current` command, you can see that the revision
hash has changed:

```console
$ kubectl exec -i -t deployment/reana-server -c rest-api -- reana-db alembic current
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
4801b98f6408
```

For more information about these commands, please refer to the
command-line tool help by adding `--help` to any of the aforementioned
commands.
