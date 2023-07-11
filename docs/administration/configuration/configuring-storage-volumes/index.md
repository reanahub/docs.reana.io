# Configuring storage volumes

As described in the [Deploying at scale](../../deployment/deploying-at-scale/index.md) documentation page, REANA needs a shared filesystem to store the workflows' workspaces.
It is also recommended to configure a second optional storage volume to be used by REANA's infrastructure components, such as the database and the message broker, in order to better isolate the infrastructure storage from possible disk exhaustion situations due to heavy user workloads.

## Configuration

The shared storage volume and the infrastructure storage volume can be configured by means of two [Helm values](https://github.com/reanahub/reana/tree/master/helm/reana):

- `shared_storage` holds the configuration for the shared filesystem needed by REANA.
  It is mandatory to configure this volume.
- `infrastructure_storage` configures the second optional volume used by the database and the message broker.
  If not configured, the shared storage volume is used instead.

This is how you would configure both volumes, with the shared storage volume being hosted on CephFS and the infrastructure one on NFS:

```yaml
infrastructure_storage:
  backend: nfs
  volume_size: 10
  access_modes: ReadWriteMany

shared_storage:
  backend: cephfs
  volume_size: 200
  access_modes: ReadWriteMany
  cephfs: ...
```

In the configuration examples below we'll use the `shared_storage` volume, but the `infrastructure_storage` volume can be configured in exactly the same way.
Note that typically, the shared storage volume can be huge (even tens of terabytes), while the shared storage volume can be as small as a few gigabytes, depending also on whether you are using an external database or not.

### CephFS

To use an existing CephFS share, set the `shared_storage.backend` Helm value to `cephfs`.
You can then configure the CephFS share by setting the appropriate values in `shared_storage.cephfs`.

This is an example CephFS configuration, using the default values present in the Helm chart:

```{ .yaml .copy-to-clipboard }
shared_storage: # or `infrastructure_storage`
  backend: cephfs
  volume_size: 200
  access_modes: ReadWriteMany
  cephfs:
    provisioner: manila-provisioner
    type: "Geneva CephFS Testing"
    availability_zone: nova
    os_secret_name: os-trustee
    os_secret_namespace: kube-system
    cephfs_os_share_id: <cephfs-share-id>
    cephfs_os_share_access_id: <cephfs-share-access-id>
```

### NFS

You can deploy an NFS file system inside your cluster using the official [NFS Server Provisioner](https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner) Helm chart.

1. Create your configuration file, `nfs-provisioner-values.yaml`, following the [documentation](https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner#recommended-persistence-configuration-examples) and adapting it to your needs. Remember to name the storage class as REANA expects it, `<helm-release-prefix>-shared-volume-storage-class`.

    ```yaml hl_lines="3"
    storageClass:
      defaultClass: true
      name: reana-shared-volume-storage-class
    ```

2. Install the NFS Server Provisioner

    ```{ .console .copy-to-clipboard }
    $ helm install reana-dev-storage stable/nfs-server-provisioner \
                  -f nfs-provisioner-values.yaml
    ```

3. Configure the NFS storage volume in your Helm configuration file

    ```{ .yaml .copy-to-clipboard }
    shared_storaged: # or `infrastructure_storage`
      backend: nfs
      volume_size: 200
      access_modes: ReadWriteMany
    ```

### HostPath

REANA also supports using directories already present on the host node's filesystem. Note that this approach is not suitable for multi-node deployments, but only for local single-user single-node instances of REANA, for example during personal development.

!!! warning
    Using HostPath volumes is not recommended, as they present many security risks. See the related [Kubernetes documentation page](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath) for more information.

To use a local directory as a storage volume, set the `shared_storage.backend` Helm value to `hostpath` and `shared_storage.hostpath.root_path` to the path of the directory you would like to use:

```{ .yaml .copy-to-clipboard }
shared_storage: # or `infrastructure_storage`
  backend: hostpath
  hostpath:
    root_path: "/opt/myreana"
```

## Separating infrastructure storage volume

REANA deployment chart uses only the single shared storage volume by default.
If you have an existing cluster with many users with heavy disk space needs, and you would like to introduce the additional infrastructure storage volume to better isolate the infrastructure components' storage needs from user workloads, you can proceed as follows.

!!! danger
    This procedure is delicate and it can lead to data loss. Carefully read the following instructions and, if possible, try them out on a test instance of REANA to make sure that everything works.

!!! note
    This guide requires to upgrade REANA a few times by using the `helm` tool. To make sure that you are running the correct commands, you can use the [`helm-diff`](https://github.com/databus23/helm-diff) plugin to inspect the changes that will be made to REANA's deployment.

1. Make sure REANA is already updated to version 0.9.0 or greater. In the following steps, we will refer to this version as `$VERSION`.
2. Disable the scheduling of new workflows by setting `REANA_MAX_CONCURRENT_BATCH_WORKFLOWS` to zero.

    ```{ .console .copy-to-clipboard}
    $ helm upgrade reana reanahub/reana \
        --version $VERSION \
        --values myvalues.yaml \
        --set components.reana_server.environment.REANA_MAX_CONCURRENT_BATCH_WORKFLOWS=0
    ```

3. Wait for all the running workflows to finish. You can run `kubectl get pods` to make sure that workflows are not running.
4. Update `myvalues.yaml` to configure the new infrastructure volume, as explained in the [Configuration](#configuration) section. For example:

    ```{ .yaml .copy-to-clipboard }
    infrastructure_storage:
      backend: cephfs
      volume_size: 200
      access_modes: ReadWriteMany
      cephfs:
        provisioner: manila-provisioner
        type: "Geneva CephFS Testing"
        availability_zone: nova
        os_secret_name: os-trustee
        os_secret_namespace: kube-system
        cephfs_os_share_id: <cephfs-share-id>
        cephfs_os_share_access_id: <cephfs-share-access-id>
    ```

5. Run `helm upgrade` to deploy the new volume and to enter maintenance mode.

    ```{.console .copy-to-clipboard }
    $ helm upgrade reana reanahub/reana \
        --version $VERSION \
        --values myvalues.yaml \
        --set components.reana_server.environment.REANA_MAX_CONCURRENT_BATCH_WORKFLOWS=0 \
        --set maintenance.enabled=true
    ```

6. Make sure that all the pods were terminated by checking the output of `kubectl get pods`.
7. Migrate the RabbitMQ and database directories from the shared volume to the new infrastructure volume.

    As an example, this can be achieved by executing a custom pod that mounts both volumes. Please note that if volumes use the `hostpath` backend, then you need to amend `migration-pod.yaml` to mount the correct paths. You also need to amend the pod's specification if you are using an external database, as in this case the database directory does not exist on the shared storage volume.

    ??? note "migration-pod.yaml"

        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
          name: reana-volume-migration
        spec:
          containers:
            - name: reana-volume-migration
              image: docker.io/library/ubuntu:20.04
              command:
                - "bash"
                - "-c"
                - |
                  set -e

                  SRC_DB=/var/reana-shared/db
                  DST_DB=/var/reana-infrastructure/db
                  SRC_MQ=/var/reana-shared/rabbitmq
                  DST_MQ=/var/reana-infrastructure/rabbitmq

                  if [ -e $DST_DB ]; then
                    echo "$DST_DB already exists, aborting"
                    exit 1
                  fi

                  if [ -e $DST_MQ ]; then
                    echo "$DST_MQ already exists, aborting"
                    exit 1
                  fi

                  echo "Moving DB to infrastructure volume"
                  mv $SRC_DB $DST_DB
                  echo "Moving MQ to infrastructure volume"
                  mv $SRC_MQ $DST_MQ
                  echo "All done!"
              volumeMounts:
                - name: reana-shared-storage
                  mountPath: "/var/reana-shared"
                - name: reana-infrastructure-storage
                  mountPath: "/var/reana-infrastructure"
          restartPolicy: Never
          volumes:
            - name: reana-shared-storage
              # hostPath:
              #   path: "/var/reana"
              persistentVolumeClaim:
                claimName: reana-shared-persistent-volume
            - name: reana-infrastructure-storage
              # hostPath:
              #   path: "/var/reana-infra"
              persistentVolumeClaim:
                claimName: reana-infrastructure-persistent-volume
        ```

    To spawn the pod, simply run `kubectl apply -f migration-pod.yaml`

8. Check the logs to make sure there are no errors and check that the directories of the database and message broker are now in the newly-created volume.

    ```console
    $ kubectl logs reana-volume-migration
    Moving DB to infrastructure volume
    Moving MQ to infrastructure volume
    All done!
    ```

9. Disable maintenance mode and scale up the cluster to start accepting new workflows.

    ```{ .console .copy-to-clipboard }
    $ helm diff upgrade reana helm/reana -f myvalues.yaml
    ```
