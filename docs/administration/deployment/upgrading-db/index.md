# Upgrading database

If you are the REANA cluster administrator upgrading an existing REANA
cluster deployment from one REANA release series to another, such as
from 0.7.* to 0.8.0, there might be changes in the REANA database schema
between the two versions. In these cases, it is necessary to run a
database upgrade script using [`alembic`](https://alembic.sqlalchemy.org/en/latest/).

The `reana-db` command-line tool is provided to ease the database
upgrade tasks. The tool is included in the `REANA-Server` component.

Two different procedures will be explained. The first, covers a quick
database upgrade after a successful cluster upgrade. The second, covers
a more detailed upgrade procedure, in case you want to have a better
control or you need to troubleshoot some unexpected issues during the
upgrade.

## Quick upgrade procedure

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

## Detailed upgrade procedure

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
