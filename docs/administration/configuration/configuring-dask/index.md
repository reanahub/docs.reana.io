# Configuring Dask

Dask integration in REANA allows users to request dedicated Dask clusters for their workflow requirements. Each cluster operates independently, providing the computational resources necessary to efficiently execute workflows.

## Enabling Dask

Dask support is disabled by default in REANA. If you would like to enable them so that users can ask for a Dask cluster for their workflow, you can set [`dask.enabled`](https://github.com/reanahub/reana/tree/master/helm/reana) Helm value to `true`.

!!! warning

    When upgrading your cluster using the `helm upgrade` command instead of `helm install`, Dask custom resource definitions may not install properly due to how Helm manages CRDs. See [this GitHub issue](https://github.com/helm/helm/issues/6581) for more details.
    When using `helm upgrade`, you'll need to manually install Dask CRDs:

    ```console
    $ helm install --repo https://helm.dask.org --generate-name dask-kubernetes-operator
    ```

    See [this GitHub issue](https://github.com/helm/helm/issues/6581) for more details.

## Configuring Autoscaler

Each Dask cluster in REANA comes with an autoscaler by default. If you would like to disable autoscaler feature, you can set the [`dask.autoscaler_enabled`](https://github.com/reanahub/reana/tree/master/helm/reana) Helm value to `false`.

The autoscaler manages the Dask cluster for your workflow by scaling up to a maximum of N workers when needed and scaling down during less resource-intensive periods. You can define the number of workers (N) in your `reana.yaml` file or use the default worker count set for Dask clusters.

For more details on how the autoscaler works under the hood, you can check the [official Dask Kubernetes Operator autoscaler documentation](https://kubernetes.dask.org/en/latest/operator_resources.html#daskautoscaler).

## Limiting Cluster Memory

The maximum memory allocated for a Dask cluster can be configured using the [dask.cluster_max_memory_limit](https://github.com/reanahub/reana/tree/master/helm/reana) Helm value which is set to `16Gi` by default. This setting defines the upper memory limit that can be requested for a cluster by users, based on the combined memory usage of all workers.

For instance, if the `dask.cluster_max_memory_limit` is set to 9Gi, a user can request a cluster with 3 workers, each utilizing up to 3Gi of memory. Any configuration exceeding this limit (e.g., 5 workers with 2Gi each, totaling 10Gi) will not be permitted.

## Configuring Default and Maximum Number Of Workers

When configuring Dask clusters in REANA, there are two important Helm values to control the number of workers in a cluster:

### [`dask.cluster_default_number_of_workers`](https://github.com/reanahub/reana/tree/master/helm/reana)

This value determines the default number of workers assigned to a Dask cluster if the user does not explicitly specify the `number_of_workers` field in their `reana.yaml` workflow configuration file. Setting this value ensures that all Dask clusters start with a reasonable number of workers to handle typical workloads without requiring user input.

For example:

```yaml
dask:
  cluster_default_number_of_workers: 3
```

In this case, every Dask cluster will start with 3 workers unless a different number is provided in the reana.yaml

If the cluster administrator does not overwrite the `dask.cluster_default_number_of_workers` variable, it is set to `2` by default.

### [`dask.cluster_max_number_of_workers`](https://github.com/reanahub/reana/tree/master/helm/reana)

This value defines the upper limit on the number of workers a user can request in their reana.yaml, even if their workflow does not reach the cluster_memory_limit. It acts as a safeguard to prevent users from requesting an excessive number of workers with very low memory allocations (e.g., 100 workers with only 30Mi memory).

```yaml
dask:
  cluster_max_number_of_workers: 50
```

In this case, users can request up to 50 workers in their reana.yaml. If they attempt to request more than the maximum limit, the system will cap the cluster size to 50 workers, regardless of the memory limits.

If the cluster administrator does not overwrite the `dask.cluster_max_number_of_workers` variable, it is set to `20` by default.

## Configuring Default and Maximum Memory for Single Workers

In addition to managing the number of workers in a Dask cluster, it is crucial to configure memory limits for individual workers to ensure resource efficiency and prevent workloads from exceeding the capacity of your cluster nodes. REANA provides two Helm values for controlling the default and maximum memory allocation per worker:

### [`dask.cluster_default_single_worker_memory`](https://github.com/reanahub/reana/tree/master/helm/reana)

```yaml
dask:
  cluster_default_single_worker_memory: "2Gi"
```

This value sets the default memory allocated to a single worker in a Dask cluster if the user does not specify the `single_worker_memory` field in their `reana.yaml` workflow configuration file.

For example:

In this case, if the user does not explicitly set a memory limit for their workers, each worker in the Dask cluster will be allocated 2Gi of memory by default. This ensures a predictable baseline configuration for workflows.

If the cluster administrator does not overwrite the `dask.cluster_default_single_worker_memory` variable, it is set to `2Gi` by default.

### [`dask.cluster_max_single_worker_memory`](https://github.com/reanahub/reana/tree/master/helm/reana)

This value defines the upper memory limit that a user can request for a single worker in their reana.yaml. It acts as a safeguard to prevent users from allocating more memory than the underlying Kubernetes nodes can handle, which could lead to scheduling failures.

For example:

```yaml
dask:
  cluster_max_single_worker_memory: "15Gi"
```

In this case, users can request up to 15Gi of memory for each worker. Any request exceeding this limit (e.g., 20Gi) will be rejected. This ensures that users cannot allocate more memory than is safe for the cluster's infrastructure.

If the cluster administrator does not overwrite the `dask.cluster_max_single_worker_memory` variable, it is set to `8Gi` by default.
