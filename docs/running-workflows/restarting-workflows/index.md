# Restarting workflows

In the [executing workflows](../executing-workflows/) page we discussed how to run and execute workflows.
REANA gives users the possibility to *restart* a workflow as well.
To restart a workflow, use the  `reana-client restart` command:

```console
$ reana-client restart -w my-physics-analysis.2
==> SUCCESS: my-physics-analysis.2.1 has been queued
```

This presents some important differences compared to re-running a workflow one more time.

## Differences between running and restarting a workflow

### Run number

In REANA, every workflow is identified by a name and a run number (e.g. `my-physics-analysis.3.1`, in which
`my-physics-analysis` is the name, and `3.1` is the run number).
The run number is made of two parts, separated by a dot: the first is the major run number (`3` in the previous example),
and the second is the minor run number (`1` in the previous example).

When you run a workflow for the first time, the run number is `1.0`. After running a new workflow with the same name,
the major run number will be incremented, and the minor run number will be set to `0`. When restarting a workflow,
instead, the major run number will remain the same, and the minor run number will be incremented.

You don't have to always specify the full run number to identify a workflow.
If the major run number is specified, but the minor run number is not, the latter is assumed to be `0`.
If the whole run number is omitted, the latest run of the workflow will be used.

Here's an example of a sequence of runs:

```console
$ reana-client run -w my-physics-analysis
==> SUCCESS: my-physics-analysis.1 has been queued

$ reana-client run -w my-physics-analysis
==> SUCCESS: my-physics-analysis.2 has been queued

$ reana-client restart -w my-physics-analysis.1
==> SUCCESS: my-physics-analysis.1.1 has been queued

$ reana-client restart -w my-physics-analysis.1
==> SUCCESS: my-physics-analysis.1.2 has been queued

$ reana-client restart -w my-physics-analysis
==> SUCCESS: my-physics-analysis.2.1 has been queued

$ reana-client restart -w my-physics-analysis
==> SUCCESS: my-physics-analysis.2.2 has been queued
```

And another example, showing how omitting parts of the run number helps you refer to the correct workflow:

```console
$ reana-client status -w my-physics-analysis.2.1 --format name,run_number
NAME                  RUN_NUMBER
my-physics-analysis   2.1

$ reana-client status -w my-physics-analysis.2 --format name,run_number
NAME                  RUN_NUMBER
my-physics-analysis   2.0

$ reana-client status -w my-physics-analysis --format name,run_number
NAME                  RUN_NUMBER
my-physics-analysis   2.2
```

### Workspace sharing

When you execute a workflow with `reana-client run`, a new workspace is created. You can think of a workspace as
an isolated folder, only accessible to your workflow, to which all the input files are uploaded before the start
of the workflow, and in which the produced files are stored.

When restarting a workflow, however, the newly created workflow will be reusing the same workspace as the
original one.
In other words, all the workflows with the same major run number will share the same workspace.

This means that the new files might overwrite the old ones. For this reason, it's important to make sure to save the results of the previous run that you want to keep before
restarting a workflow.

## Why restarting a workflow?

Restarting a workflow is especially useful in the workflow development phase. This is true for a variety of reasons.

### Experimenting with incremental changes

When you are developing a workflow, you often need to make incremental changes to the workflow definition, and
the `reana-client restart` command allows you to pass a new workflow specification file using the `-f` (`--file`) option.
This flexibility means you can test variations in your workflow's logic (or parameters with the `-p` option)
on the fly, without the overhead of managing multiple workspaces or losing the context of your previous runs.

### Saving disk space

Restarting a workflow makes it much easier to save disk quota, as the same workspace will be reused across the multiple
runs, avoiding to duplicate the same files over multiple workspaces. This is particularly useful when the workflow
is still in development, and you are running it multiple times to test it.

### Using Snakemake workflow cache

Snakemake workflows benefit particularly from the `restart` feature, as running a new workflow in the same workspace
enables Snakemake to restore the results of the previous run from its internal cache and only re-run the necessary steps.
If you prefer avoiding this, you should run a new workflow instead of restarting the old one.

### Re-executing only parts of a serial workflow

When restarting a serial workflow with named steps, you can use the `FROM` / `TARGET` operational options to choose exactly
the starting step and the ending step of the re-execution, to re-run only a part of the workflow.
This targeted approach allows for focused debugging or re-analysis of specific workflow segments without rerunning the
entire process. Here's an example:

```console
$ reana-client restart -w myanalysis.42 -o TARGET=gendata

$ reana-client restart -w myanalysis.42 -o FROM=fitdata
```
