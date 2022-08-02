# Workspace retention rules

There could be situations where you would like to preserve some files in your workflow's workspace for a limited time.
By doing that, for example, you can free up storage space to stay within your [quota limits](/advanced-usage/user-quotas).
REANA allows you to keep files for a limited time using **retention rules**.
Below you can find details about configuring retention rules for your workflow.

## Configuring retention rules in reana.yaml

Retention rules are specified in `reana.yaml` file as follows:

```yaml
...
workspace:
  retention_days:
    tmp/*.root: 7
    data/*.json: 30
...
```

They consist of two parts:

- *pattern* (e.g, `tmp/*.root`) that specifies which files are affected,
- *duration* (e.g, `7`) that indicates for how many *days* to keep files.

The retention rules start applying **after** workflow finishes or fail.
So, taking the example from above, the rule `tmp/*.root: 7` means "when workflow finishes or fails, delete files with ROOT extension in tmp directory after 7 days".

!!! note
    REANA will not apply the retention rules to the files and directories specified in *inputs* and *outputs* of `reana.yaml`. 
    This ensures that your workflows can be reproduced even after applying retention rules.
    If you no longer need inputs and outputs, consider deleting workflow manually.

Here you can find a table of all available patterns to match files and directories:

| Pattern   | Meaning                                                  |     
| --------- | -------------------------------------------------------- | 
| `*`       | match everything                                         |  
| `**`      | match this directory and all subdirectories, recursively |
| `?`       | matches any single character                             |
| `[seq]`   | matches any character in a sequence                      |
| `![seq]`  | matches any character *not* in a sequence                |

The useful pattern to recursively match *all* directories and files in your workspace is `**/*`.
For example, this rule will delete all directories and files in the workspace after 30 days:

```yaml
workspace:
  retention_days:
    **/*: 30
```

## What happens when a workflow is restarted?

When you restart a workflow, current and previous restarted workflows share the same workspace.
REANA will only consider retention rules from the latest restart and ignore rules from the earlier restarts.

## Limitation on the maximum numbers of retention days

Administrators of the REANA cluster can set a default retention period for the entire workspace depending on the storage needs.
In that case, if the administrator setups the maximum allowed retention days to, for example, 365 days,
it will not be possible to use duration for retention rules bigger than 365 days in `reana.yaml`.


