# Configuring global workspace retention rules

As of version 0.9, REANA administrators can configure a global workspace file retention period after which all the files produced by user workflows that are not declared as `inputs` or `outputs` will be automatically deleted.
By default, every file is kept indefinitely.

If you would like to limit the workspace file retention period globally, you can configure the [`workspaces.retention_rules.maximum_period`](https://github.com/reanahub/reana/tree/master/helm/reana#configuration) Helm value to the desired amount of days, such as 3650.
This will make sure that all files produced by users will be kept at most for ten years.
Note that users will be able to define their individually desired [retention rules](/advanced-usage/workspace-retention) to a period not exceeding this global maximum.

We recommend to keep the [`workspaces.retention_rules.maximum_period`](https://github.com/reanahub/reana/tree/master/helm/reana#configuration) Helm value to its default value `forever` and rather use the user disk storage [resource quotas](/administration/configuration/configuring-user-quotas) to limit the amount of storage that each user can consume.

Note that if you redeploy REANA and modify its [`workspaces.retention_rules.maximum_period`](https://github.com/reanahub/reana/tree/master/helm/reana#configuration) settings between two rolling deployments, e.g. from `forever` to `3650`, the new workflows will use the updated global maximum retention period (ten years) while the old workflows will keep using older default (forever).
