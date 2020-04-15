# Deploying at scale

REANA can be easily deployed on large Kubernetes clusters using Helm. Useful for production instances.

## Pre-requisites

- A Kubernetes `v1.16.3` cluster is required as well as Helm `v3.0.x`.

- A shared file system to host all analyses workspaces when running in a multinode deployment setup. Therefore, you should create an [`StorageClass`](https://kubernetes.io/docs/concepts/storage/storage-classes/#the-storageclass-resource) pointing to your storage backend. The `StorageClass` should meet the following requirements:
    - be named `<helm-release-prefix>-shared-volume-storage-class`;
    - be created in the same namespace as the one you will deploy REANA to.

    For example, [CERN uses CephFS](https://clouddocs.web.cern.ch/containers/tutorials/cephfs.html) as the default storage backend.

!!! note
    If you do not have any particular distributed file system in your Kubernetes cluster, you can easily [deploy an NFS network file system following our documentation](../../advanced-usage/storage-backends/nfs).

## Deploy

**1.** Add REANA chart repository:

```console
$ helm repo add reanahub https://reanahub.github.io/reana
"reanahub" has been added to your repositories
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "reanahub" chart repository
...Successfully got an update from the "cern" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
```

**2.** Deploy REANA (note that you can pass any of the [supported values](https://github.com/reanahub/reana/blob/master/helm/reana/README.md)):

```console
$ helm install reana reanahub/reana --wait
NAME: reana
LAST DEPLOYED: Wed Mar 18 10:27:06 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thanks for flying REANA 🚀
```
