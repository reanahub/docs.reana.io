# Configuring workspace retention rules

REANA allows users to keep files in their workflows for a limited time using **retention rules**.
Controlling how long to retain files can reduce storage space usage.
On this page, you can find details on how to enable retention rules for the REANA cluster.
To learn more about retention rules, please, check [this page](/advanced-usage/workspace-retention-rules).
Let's get started.

By default, retention rules are disabled for the REANA cluster.
You can enable them by modifying [`workspaces.retention_rules.maximum_period`](https://github.com/reanahub/reana/tree/master/helm/reana#configuration) parameter.
For example, the parameter below will set the default retention period for 30 days for all files in each workflow:

```yaml
workspaces.retention_rules.maximum_period: 30
```

!!! note
    Users will not be able to set a retention period higher than one specified in `workspaces.retention_rules.maximum_period`.
    But, users can use lower retention values according to their needs.

Use the `forever` value to explicitly disable the maximum retention period and allow users to set up any number of days.

```yaml
workspaces.retention_rules.maximum_period: forever
```

If you found this feature interesting, consider checking [the user quotas feature](/advanced-usage/user-quotas) that allows limiting the number of resources each user can have.

## What happens if default retention period is updated for a cluster?

If `workspaces.retention_rules.maximum_period` is updated, all new workflows will automatically use the updated default retention period.
Workflows created before the update will still use the old default retention period.

In case, for example, you are changing the default retention period from `forever` to a limited number of days.
It is important to remember that older workflows will retain files forever.
If this is an issue, you will need manually contact users and ask them to clean their workspaces.
