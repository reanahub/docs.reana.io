# Deploying at scale

REANA can be easily deployed on large Kubernetes clusters using Helm. Useful for production instances.

## Pre-requisites

- A Kubernetes `v1.16.3` cluster is required as well as Helm `v3.2.x`.

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
$ helm install --devel reana reanahub/reana --wait
NAME: reana
LAST DEPLOYED: Wed Mar 18 10:27:06 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thanks for flying REANA 🚀
```

!!! warning

    Note that the above `helm install` command used `reana` as the Helm release name. You can choose any other name provided that it is less than 13 characters long. (This is due to current limitation on the length of generated pod names.)

!!! note
    Note that you can deploy REANA in different namespaces by passing `--namespace` to `helm install`. Remember to pass `--create-namespace` if the namespace you want to use does not exist yet. For more information on how to work with namespaces see the [official documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/).

## Advanced deployment scenarios

### High availability

REANA infrastructure services are critical for the platform to properly work, therefore it is a good technique to deploy them in dedicated nodes different from ones used to run user workflows. To achieve this:

**1.** Create a multi-node Kubernetes cluster and check your nodes:

```console
$ kubectl get nodes
NAME    STATUS   ROLES    AGE   VERSION
node1   Ready    master   97m   v1.18.2
node2   Ready    <none>   97m   v1.18.2
node3   Ready    <none>   97m   v1.18.2
node4   Ready    <none>   97m   v1.18.2
```

**2.** Label your nodes according to the responsibility they should take; `reana.io/system: infrastructure` for infrastructure nodes and `reana.io/system: runtime` for runtime nodes. For example:

```console
$ kubectl label nodes node2 reana.io/system=infrastructure
$ kubectl label nodes node3 node4 reana.io/system=runtime
```

**3.** Configure REANA's `values.yaml` to specify the labels for runtime and infrastructure nodes:

```diff
+node_label_infrastructure: reana.io/system=infrastructure
+node_label_runtime: reana.io/system=runtime
```

**4.** Deploy REANA.
