# Workspace retention

REANA usually holds all your workflow workspace files "forever", i.e. until you actively decide to delete them.

However, there could be situations where you would like to keep some files in your workflow's workspace only for a limited period of time after the workflow execution ends.
For example, your workflow could generate huge temporary files that consume your [disk quota](/advanced-usage/user-quotas).

REANA allows you to configure the automatic deletion of unnecessary temporary files of this nature by defining custom *workspace file retention rules* in the `reana.yaml` specification of your workflow.

This feature is similar to [GitLab job artifacts expiry](https://docs.gitlab.com/ee/ci/yaml/index.html#artifactsexpire_in) or [GitHub Actions artifacts retention period](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration#artifact-and-log-retention-policy).

## Defining custom workspace file retention rules

Custom retention rules for your workflow runs can be specified in the `reana.yaml` file as follows:

```yaml
...
workspace:
  retention_days:
    tmp1: 1
    tmp2/*.root: 7
    tmp3/*.csv: 30
...
```

Each rule consists of two parts:

- file name pattern (e.g. `tmp2/*.root`) that specifies which files and directories are affected by the rule;
- retention period in days (e.g. `7`) that specifies after how many days the files and directories can be automatically deleted.

For instance, considering the example above, after the workflow run terminates, the files in `tmp1` will be kept for one day, the files `tmp2/*.root` for 7 days and the files `tmp3/*.csv` for 30 days.

!!! note
    REANA will not apply the retention rules to files and directories specified in the *inputs* and *outputs* of `reana.yaml`.
    This ensures that your workflows can be reproduced even after applying the retention rules. If you no longer need inputs and outputs, consider deleting the files or the workflow manually by means of `reana-client rm` command.

Here you can find a table of all available patterns to match files and directories:

| Pattern  | Meaning                                                  |
| -------- | -------------------------------------------------------- |
| `*`      | match any character                                      |
| `**`     | match this directory and all subdirectories, recursively |
| `?`      | match any single character                               |
| `[seq]`  | match any single character in `seq`                      |
| `[!seq]` | match any single character *not* in `seq`                |

Note that you can combine the above patterns together, for example `mystage[12]/mydata*.csv` will delete all CSV files whose names start by `mydata` from `mystage1` and `mystage2` directories, but not from `mystage3` or `mystage4`.

The useful pattern to recursively match *all* directories and files in your workspace is `**/*`.
For example, this rule will delete all directories and files in the workspace 30 days after the workflow run execution terminates (excluding declared inputs and outputs):

```yaml
workspace:
  retention_days:
    "**/*": 30
```

## Restarting a workflow

When you restart a workflow, the current and the previous runs of the workflow share the same workspace.
The workspace file retention rules of restarted runs will therefore operate on the same physical workspace.
REANA will only consider the retention rules defined in the latest restart, which will override the rules from previous restarts.

## Limits on the maximum number of retention days

Administrators of the REANA cluster can set a global maximum retention period for your workflows, for example ten years. You can check the global maximum retention period of your REANA cluster using the command line:

```console
$ reana-client info
...
Maximum retention period in days for workspace files: 3650
...
```

You will not be able to set longer retention periods than the global maximum in your `reana.yaml` specifications.
The value `None` means that there is no theoretically imposed maximum limit on the retention days you can use.

## Verifying retention period

You can verify the custom retention period settings for any of your workflow runs using the REANA web interface's Workspace tab, where you will be also notified about upcoming scheduled file deletions:

![Workspace file retention rules in the Workspace tab](/images/ui-retention-rules.png)

You can also achieve the same by means of the `reana-client` command-line client:

```console
$ reana-client retention-rules-list -w reana-demo-root6-roofit
WORKSPACE_FILES   RETENTION_DAYS   APPLY_ON              STATUS
tmp1              1                2022-12-06T23:59:59   active
tmp2/*.root       7                2022-12-12T23:59:59   active
tmp3/*.csv        30               2023-01-04T23:59:59   active
```
