# Configuring user quotas

Since [REANA 0.8.0 release](https://blog.reana.io/posts/2021/release-0.8.0/#cpu-and-disk-quota-accounting),
it is possible to configure quotas to limit usage of CPU and disk by users.
On this page, you will find a guide on enabling quotas for the REANA cluster and setting limits.
If you are looking for documentation from the user perspective, please, check [this page](https://docs.reana.io/advanced-usage/user-quotas/).

## Enabling quotas

By default, quotas are enabled in REANA. But, to be sure, you can always modify `quota.enabled` Helm value in [`values.yaml`](https://github.com/reanahub/reana/tree/master/helm/reana#configuration).

```yaml
quota:
  enabled: true
```

REANA automatically creates two quota resources for you:

- `cpu`, to limit the time for running workflows;
- `disk`, to limit the storage space available for file uploads.

In addition to enabling quotas, you might want to decide on how frequently quotas should be updated.
This is done using two options `quota.periodic_update_policy` and `quota.workflow_termination_update_policy`.

`quota.periodic_update_policy` option defines when periodic cron job should update quotas. By default, it is set to run once every night.

`quota.workflow_termination_update_policy` option is responsible for defining what resources should be updated after the workflow is in its final state (finished, failed, etc.).

Below you can find the example configuration of those two options.

```yaml
quota:
  enabled: true
  periodic_update_policy: "0 3 * * *"  # everyday at 3AM
  workflow_termination_update_policy: "cpu,disk"  # after workflow finishes or fails update its cpu and disk resources usage
```

## Setting default quota limits

Now when user quotas are enabled, you may want to set a default quota limit that will apply to all new users.
This can be done via `quota.default_disk_limit` and `quota.default_cpu_limit` values:

```yaml
quota:
  default_disk_limit: 5000000000  # bytes (4768 MB) 
  default_cpu_limit: 3600000      # milliseconds (1 hour)
  ...
```

!!! note
    If default quota values are changed, they will only be applied to newly created users. Users before will still have old values for quotas.

## Setting quotas for selected users

In certain situation, you might want to set quotas for specific users.
This can be done via `reana-admin` tool that is present in `reana-server` pod in REANA cluster.
Let's take a look how you use it.

Log in to `reana-server` pod.

```console
$ kubectl exec -i -t deployment/reana-server -- /bin/bash
```

Inside the pod, set a quota to a selected user(s).

```console
# flask reana-admin quota-set -e john.doe@example.org -r disk -l 250000
```

You can learn about different management commands of `reana-admin` using `flask reana-admin --help` command.
