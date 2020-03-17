# NFS

As described in the [deploying at scale documentation](../../../development/deploying-at-scale/index.md), REANA needs a shared file system.

You can deploy an NFS file system inside your cluster using the official [NFS Server Provisioner](https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner) Helm chart.

- **1.** Create your configuration file, `nfs-provisioner-values.yaml`, following the [documentation](https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner#recommended-persistence-configuration-examples) and adapting it to your needs. Remember to name the storage class as REANA expects it, `<helm-release-prefix>-shared-volume-storage-class`.

```yaml hl_lines="3"
storageClass:
  defaultClass: true
  name: reana-shared-volume-storage-class
```

- **2.** Install the NFS Server Provisioner:

```console
$ helm install reana-dev-storage stable/nfs-server-provisioner \
               -f nfs-provisioner-values.yaml
```

- **3.** Install REANA with NFS support:

```console
$ helm install reana reanahub/reana --set shared_storage.backend=nfs
```
