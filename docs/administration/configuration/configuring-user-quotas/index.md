# Configuring user quotas

Since [REANA 0.8.0](https://blog.reana.io/posts/2021/release-0.8.0/#cpu-and-disk-quota-accounting),
it is possible to configure user quotas to limit the usage of resources, such as CPU and disk storage.
This page describes how to enable quotas on your REANA cluster and how to set usage limits.
If you are looking for documentation from the user perspective, please check [this page](https://docs.reana.io/advanced-usage/user-quotas/).

## Enabling and disabling quotas

Quotas are enabled by default in REANA. If you would like to disable them, you can set the [`quota.enabled`](https://github.com/reanahub/reana/tree/master/helm/reana) Helm value to `false`.

REANA automatically creates two user quota resources for you:

- `cpu` to limit the amount of CPU time available to run workflows;
- `disk` to limit the total storage space in user workflow's workspaces.

In addition to enabling quotas, you might want to decide how frequently the quota resources usage should be tracked and updated.
This is done using two options:

- [`quota.periodic_update_policy`](https://github.com/reanahub/reana/tree/master/helm/reana) Helm value defining a policy where users' quota resources usage is updated periodically via a cron job. The value is a [cron expression](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#schedule-syntax) and it indicates how frequently the cron job should run. By default, the value is set to `"0 3 * * *"`, meaning that the quota usage updates are carried out daily at 03:00 in the morning.
- [`quota.workflow_termination_update_policy`](https://github.com/reanahub/reana/tree/master/helm/reana) Helm value defining a policy where users' quota resources usage is updated as soon as each workflow run terminates. This policy is not enabled by default because it could lead to slower workflow termination times when the REANA system runs many concurrent user workflows.

Here is an example of a mixed configuration where, in addition to nightly CPU and disk quota usage updates, the CPU usage is also updated immediately after each workflow run terminates:

```yaml
quota:
  enabled: true
  # update quota usage every day at 3AM
  periodic_update_policy: "0 3 * * *"
  # after workflow finishes or fails update its cpu usage
  workflow_termination_update_policy: "cpu"
```

## Setting default quota limits

When user quotas are enabled, no limit on the actual usage of resources by the users is enforced by default. You could however set a default quota limit that will apply to each user by means of setting the [`quota.default_disk_limit`](https://github.com/reanahub/reana/tree/master/helm/reana) and [`quota.default_cpu_limit`](https://github.com/reanahub/reana/tree/master/helm/reana) Helm values:

```yaml
quota:
  default_disk_limit: 10737418240  # bytes (10 GiB)
  default_cpu_limit: 36000000      # milliseconds (10 hours)
  ...
```

Individual users will be able to run as many workflows as they want, provided that the total CPU usage time stays under 10 hours and the total consumed disk space stays under 10 GiB.

!!! warning
    If the default quota values are changed, they will only be applied to newly created users. Users that already exist will not be affected by this change.

## Setting the default CPU quota period

As of REANA 0.95 release series, in addition to setting CPU usage limits, you
can configure REANA to track CPU time inside recurring quota periods instead
of over the whole lifetime of a user account. Renewable quota periods are
currently supported only for the `cpu` resource.

To enable a deployment-wide default CPU quota period for newly created
users, set the following Helm value to a positive integer:

```yaml
quota:
  cpu_period_reset_months: 3
```

Set `quota.cpu_period_reset_months` to `0` to disable the deployment-wide
default. The chosen value is stored per user as `quota_period_months`.

When this value is set, each newly created user receives:

- `quota_period_months` which defines the length of the CPU quota period
- `quota_period_start_at` which defines the start of the current period

The current period is derived from the user account creation time. For
example, for a user created on `2026-04-14T13:06:32` and a three-month period,
REANA will track CPU usage in successive periods such as `2026-04-14` to
`2026-07-14`, `2026-07-14` to `2026-10-14`, and so on.

As with default quota limits, changing the deployment-wide CPU quota period
only affects newly created users. Existing users keep their current
settings until they are updated manually.

If you want to backfill the deployment default CPU quota period for already
existing users, run:

```console
$ kubectl exec -i -t deployment/reana-server -- reana-db quota init-default-period
Will set the default CPU quota period for 42 users (3 months).
Proceed? [y/N]: y
Initialised the default CPU quota period for 42 existing users.
```

This command only initializes users who do not already have a custom CPU
quota period configured. Pass `--yes` to skip the confirmation prompt for
non-interactive/scripted use, or `--dry-run` to see how many users would be
affected without changing anything.

## Setting individual quota limits

In addition to setting the default quota limits for all users, you may want to set different quota usage limits for different specific groups of users.
This can be done via the `reana-admin` tool that is present in the `reana-server` pod or via the REST API.

### Using the `reana-admin` tool

Run the command inside the `reana-server` pod to set a custom quota limit for
selected users:

```console
$ kubectl exec -i -t deployment/reana-server -- flask reana-admin quota-set -e john.doe@example.org -r disk -l 250000
Quota limit 250000 for 'disk (shared storage)' successfully set to user(s): john.doe@example.org.
```

You can learn more about the `quota-set` administrative command options by running `kubectl exec -i -t deployment/reana-server -- flask reana-admin quota-set --help`.

### Using the Quota management REST API

As of REANA 0.95 release series, you can also set quota limits for specific users using the Quota management REST API at `/api/quota`.

All Quota management REST API requests must include the `X-Quota-Management-Secret` header containing the configured secret.
This secret should be set in your Helm `values.yaml` file:

```yaml
components:
  reana_server:
    environment:
      REANA_QUOTA_MANAGEMENT_SECRET: "my_secret"
```

If the secret is unset or empty, the Quota management REST API is disabled.

To get the current CPU quota limit and usage for the user `john.doe@example.org`, run:

```console
$ curl --fail-with-body -v -H "X-Quota-Management-Secret: my_secret" \
       "https://reana.example.org/api/quota?email=john.doe@example.org&resource_type=cpu"
```

The response contains the current limit and usage for the given user and resource:

```json
{
  "limit": 36000000,
  "message": "OK",
  "usage": 12000000
}
```

To set a custom disk quota limit of 250 GiB for the user `john.doe@example.org`, run:

```console
$ curl --fail-with-body -v -H "X-Quota-Management-Secret: my_secret" \
       -H "Content-Type: application/json" \
       -X POST \
       -d '{"email": "john.doe@example.org", "resource_type": "disk", "limit": 250000000000}' \
       "https://reana.example.org/api/quota"
```

The response contains the new limit and the current usage for the given user and resource:

```json
{
  "limit": 250000000000,
  "message": "OK",
  "usage": 12000000
}
```

## Setting per-user CPU quota periods

As of REANA 0.95 release series, you can also configure CPU quota periods on
a per-user basis. For example, to set a two-month CPU quota period for one
user, run:

```console
$ kubectl exec -i -t deployment/reana-server -- flask reana-admin quota-set-period -e john.doe@example.org --resource cpu --quota-period-months 2
Periodic quota fields updated successfully.
```

You can optionally provide the current period start explicitly, as either
`YYYY-MM-DD` or `YYYY-MM-DDTHH:MM:SS` (no timezone suffix; the value is
interpreted as UTC):

```console
$ kubectl exec -i -t deployment/reana-server -- flask reana-admin quota-set-period -e john.doe@example.org --resource cpu --quota-period-months 2 --quota-period-start-at 2026-05-01T00:00:00
Periodic quota fields updated successfully.
```

If you omit `--quota-period-start-at`, REANA preserves the currently stored
period start. If no period start has been stored yet, REANA initialises it from
the user account creation time and the configured period length.
The `--quota-period-start-at` value may also be set in the future.
Until that date is reached, no CPU usage is recorded against the new period
yet.

To force-start a new CPU quota period for a user, reuse
`quota-set-period` and provide only the new `--quota-period-start-at`:

```console
$ kubectl exec -i -t deployment/reana-server -- flask reana-admin quota-set-period -e john.doe@example.org --resource cpu --quota-period-start-at 2026-07-01T00:00:00
Periodic quota fields updated successfully.
```

For service integrations, the same periodic CPU fields can be managed over the
quota management REST API:

```console
$ curl -X PATCH https://reana.example.org/api/quota \
    -H 'Content-Type: application/json' \
    -H "X-Quota-Management-Secret: $REANA_QUOTA_MANAGEMENT_SECRET" \
    --data '{
      "email": "john.doe@example.org",
      "resource_type": "cpu",
      "quota_period_months": 2,
      "quota_period_start_at": "2026-05-01T00:00:00Z"
    }'
```

The REST API accepts one or both of `quota_period_months` and
`quota_period_start_at`.

## Recalculating CPU usage after changing a quota period

Changing `quota_period_months` or `quota_period_start_at` updates the stored
period metadata immediately, but it does not by itself recompute the
accumulated CPU usage for the new period.

CPU usage is recalculated when the next quota usage update runs, either
automatically on the configured `quota.periodic_update_policy` schedule, or
manually by triggering an ad-hoc run of the same cronjob.

To force an immediate refresh, spawn a one-off job from the existing
`reana-resource-quota-update` cronjob:

```console
$ kubectl create job --from=cronjob/reana-resource-quota-update \
    reana-resource-quota-update-manual-$(date +%s)
```

This command advances the current CPU quota period if needed and recalculates
each user's CPU usage for the current period only. This is particularly
useful after changing quota period settings, when you want the web UI and
REST API responses to reflect the new period immediately.
