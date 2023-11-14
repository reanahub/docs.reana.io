# reana-client CLI API

The complete `reana-client` CLI API reference guide is available here:

- [https://reana-client.readthedocs.io/en/latest/#cli-api](https://reana-client.readthedocs.io/en/latest/#cli-api)

```console
Usage:  [OPTIONS] COMMAND [ARGS]...

  REANA client for interacting with REANA server.

Options:
  -l, --loglevel [DEBUG|INFO|WARNING]
                                  Sets log level
  --help                          Show this message and exit.

Quota commands:
  quota-show  Show user quota.

Configuration commands:
  info     List cluster general information.
  ping     Check connection to REANA server.
  version  Show version.

Workflow management commands:
  create  Create a new workflow.
  delete  Delete a workflow.
  diff    Show diff between two workflows.
  list    List all workflows and sessions.

Workflow execution commands:
  logs      Get workflow logs.
  restart   Restart previously run workflow.
  run       Shortcut to create, upload, start a new workflow.
  start     Start previously created workflow.
  status    Get status of a workflow.
  stop      Stop a running workflow.
  validate  Validate workflow specification file.

Workflow sharing commands:
  share-add     Share a workflow with other users (read-only).
  share-remove  Unshare a workflow.
  share-status  Show with whom a workflow is shared.

Workspace interactive commands:
  close  Close an interactive session.
  open   Open an interactive session inside the workspace.

Workspace file management commands:
  download  Download workspace files.
  du        Get workspace disk usage.
  ls        List workspace files.
  mv        Move files within workspace.
  prune     Prune workspace files.
  rm        Delete files from workspace.
  upload    Upload files and directories to workspace.

Workspace file retention commands:
  retention-rules-list  List the retention rules for a workflow.

Secret management commands:
  secrets-add     Add secrets from literal string or from file.
  secrets-delete  Delete user secrets by name.
  secrets-list    List user secrets.
```

## Quota commands

### quota-show

Show user quota.

The ``quota-show`` command displays quota usage for the user.

Examples:

     $ reana-client quota-show --resource disk --report limit

     $ reana-client quota-show --resource disk --report usage

     $ reana-client quota-show --resource disk

     $ reana-client quota-show --resources

## Configuration commands

### ping

Check connection to REANA server.

The ``ping`` command allows to test connection to REANA server.

Examples:

     $ reana-client ping

### version

Show version.

The ``version`` command shows REANA client version.

Examples:

     $ reana-client version

### info

List cluster general information.

The ``info`` command lists general information about the cluster.

Lists all the available workspaces. It also returns the default workspace
defined by the admin.

Examples:

     $ reana-client info

## Workflow management commands

### list

List all workflows and sessions.

The ``list`` command lists workflows and sessions. By default, the list of
workflows is returned. If you would like to see the list of your open
interactive sessions, you need to pass the ``--sessions`` command-line
option.

Example:

     $ reana-client list --all

     $ reana-client list --sessions

     $ reana-client list --verbose --bytes

### create

Create a new workflow.

The ``create`` command allows to create a new workflow from reana.yaml
specifications file. The file is expected to be located in the current
working directory, or supplied via command-line -f option, see examples
below.

Examples:

     $ reana-client create

     $ reana-client create -w myanalysis

     $ reana-client create -w myanalysis -f myreana.yaml

### delete

Delete a workflow.

The ``delete`` command removes workflow run(s) from the database.
Note that the workspace and any open session attached to it will always be
deleted, even when ``--include-workspace`` is not specified.
Note also that you can remove all past runs of a workflow by specifying ``--include-all-runs`` flag.

Example:

     $ reana-client delete -w myanalysis.42

     $ reana-client delete -w myanalysis.42 --include-all-runs

### diff

Show diff between two workflows.

The ``diff`` command allows to compare two workflows, the workflow_a and
workflow_b, which must be provided as arguments. The output will show the
difference in workflow run parameters, the generated files, the logs, etc.

Examples:

     $ reana-client diff myanalysis.42 myotheranalysis.43

     $ reana-client diff myanalysis.42 myotheranalysis.43 --brief

## Workflow execution commands

### start

Start previously created workflow.

The ``start`` command allows to start previously created workflow. The
workflow execution can be further influenced by passing input prameters
using ``-p`` or ``--parameters`` flag and by setting additional operational
options using ``-o`` or ``--options``.  The input parameters and operational
options can be repetitive. For example, to disable caching for the Serial
workflow engine, you can set ``-o CACHE=off``.

Examples:

     $ reana-client start -w myanalysis.42 -p sleeptime=10 -p myparam=4

     $ reana-client start -w myanalysis.42 -p myparam1=myvalue1 -o CACHE=off

### restart

Restart previously run workflow.

The ``restart`` command allows to restart a previous workflow on the same
workspace.

Note that workflow restarting can be used in a combination with operational
options ``FROM`` and ``TARGET``. You can also pass a modified workflow
specification with ``-f`` or ``--file`` flag.

You can furthermore use modified input prameters using ``-p`` or
``--parameters`` flag and by setting additional operational options using
``-o`` or ``--options``.  The input parameters and operational options can be
repetitive.

Examples:

     $ reana-client restart -w myanalysis.42 -p sleeptime=10 -p myparam=4

     $ reana-client restart -w myanalysis.42 -p myparam=myvalue

     $ reana-client restart -w myanalysis.42 -o TARGET=gendata

     $ reana-client restart -w myanalysis.42 -o FROM=fitdata

### status

Get status of a workflow.

The ``status`` command allow to retrieve status of a workflow. The status can
be created, queued, running, failed, etc. You can increase verbosity or
filter retrieved information by passing appropriate command-line options.

Examples:

     $ reana-client status -w myanalysis.42

     $ reana-client status -w myanalysis.42 -v --json

### logs

Get workflow logs.

The ``logs`` command allows to retrieve logs of running workflow. Note that
only finished steps of the workflow are returned, the logs of the currently
processed step is not returned until it is finished.

Examples:

     $ reana-client logs -w myanalysis.42
     $ reana-client logs -w myanalysis.42 -s 1st_step

### validate

Validate workflow specification file.

The ``validate`` command allows to check syntax and validate the reana.yaml
workflow specification file.

Examples:

     $ reana-client validate -f reana.yaml

### stop

Stop a running workflow.

The ``stop`` command allows to hard-stop the running workflow process. Note
that soft-stopping of the workflow is currently not supported. This command
should be therefore used with care, only if you are absolutely sure that
there is no point in continuing the running the workflow.

Example:

     $ reana-client stop -w myanalysis.42 --force

### run

Shortcut to create, upload, start a new workflow.

The ``run`` command allows to create a new workflow, upload its input files
and start it in one command.

Examples:

     $ reana-client run -w myanalysis-test-small -p myparam=mysmallvalue

     $ reana-client run -w myanalysis-test-big -p myparam=mybigvalue

## Workflow sharing commands

### share-add

Share a workflow with other users (read-only).

The `share-add` command allows sharing a workflow with other users. The
users will be able to view the workflow but not modify it.

Examples:

<!-- markdownlint-disable no-bare-urls -->
$ reana-client share-add -w myanalysis.42 --user bob@cern.ch

<!-- markdownlint-disable no-bare-urls -->
$ reana-client share-add -w myanalysis.42 --user bob@cern.ch --user cecile@cern.ch --message "Please review my analysis" --valid-until 2024-12-31

### share-remove

Unshare a workflow.

The `share-remove` command allows for unsharing a workflow. The workflow
will no longer be visible to the users with whom it was shared.

Example:

<!-- markdownlint-disable no-bare-urls -->
$ reana-client share-remove -w myanalysis.42 --user bob@example.org

### share-status

Show with whom a workflow is shared.

The `share-status` command allows for checking with whom a workflow is
shared.

Example:

$ reana-client share-status -w myanalysis.42

## Workspace interactive commands

### open

Open an interactive session inside the workspace.

The ``open`` command allows to open interactive session processes on top of
the workflow workspace, such as Jupyter notebooks. This is useful to
quickly inspect and analyse the produced files while the workflow is stlil
running.

Examples:

     $ reana-client open -w myanalysis.42 jupyter

### close

Close an interactive session.

The ``close`` command allows to shut down any interactive sessions that you
may have running. You would typically use this command after you finished
exploring data in the Jupyter notebook and after you have transferred any
code created in your interactive session.

Examples:

     $ reana-client close -w myanalysis.42

## Workspace file management commands

### ls

List workspace files.

The ``ls`` command lists workspace files of a workflow specified by the
environment variable REANA_WORKON or provided as a command-line flag
``--workflow`` or ``-w``. The SOURCE argument is optional and specifies a
pattern matching files and directories.

Examples:

     $ reana-client ls --workflow myanalysis.42

     $ reana-client ls --workflow myanalysis.42 --human-readable

     $ reana-client ls --workflow myanalysis.42 'data/*root*'

     $ reana-client ls --workflow myanalysis.42 --filter name=hello

### download

Download workspace files.

The ``download`` command allows to download workspace files and directories.
By default, the files specified in the workflow specification as outputs
are downloaded. You can also specify the individual files you would like
to download, see examples below.

Examples:

     $ reana-client download # download all output files

     $ reana-client download mydata.tmp outputs/myplot.png

     $ reana-client download -o - data.txt # write data.txt to stdout

### upload

Upload files and directories to workspace.

The ``upload`` command allows to upload workflow input files and
directories. The SOURCES argument can be repeated and specifies which files
and directories are to be uploaded, see examples below. The default
behaviour is to upload all input files and directories specified in the
reana.yaml file.

Examples:

     $ reana-client upload -w myanalysis.42

     $ reana-client upload -w myanalysis.42 code/mycode.py

### rm

Delete files from workspace.

The ``rm`` command allow to delete files and directories from workspace.
Note that you can use glob to remove similar files.

Examples:

     $ reana-client rm -w myanalysis.42 data/mydata.csv

     $ reana-client rm -w myanalysis.42 'data/*root*'

### mv

Move files within workspace.

The ``mv`` command allows to move files within a workspace. Note that the
workflow might fail if files are moved during its execution.

Examples:

     $ reana-client mv data/input.txt input/input.txt

### prune

Prune workspace files.

The ``prune`` command deletes all the intermediate files of a given workflow that are not present
in the input or output section of the workflow specification.

Examples:

     $ reana-client prune -w myanalysis.42

     $ reana-client prune -w myanalysis.42 --include-inputs

### du

Get workspace disk usage.

The ``du`` command allows to check the disk usage of given workspace.

Examples:

     $ reana-client du -w myanalysis.42 -s

     $ reana-client du -w myanalysis.42 -s --human-readable

     $ reana-client du -w myanalysis.42 --filter name=data/

## Workspace file retention commands

### retention-rules-list

List the retention rules for a workflow.

Example:

     $ reana-client retention-rules-list -w myanalysis.42

## Secret management commands

### secrets-add

Add secrets from literal string or from file.

Examples:

     $ reana-client secrets-add --env RUCIO_USERNAME=ruciouser

     $ reana-client secrets-add --file userkey.pem

     $ reana-client secrets-add --env VOMSPROXY_FILE=x509up_u1000

                                --file /tmp/x509up_u1000

### secrets-delete

Delete user secrets by name.

Examples:

    $ reana-client secrets-delete RUCIO_USERNAME

### secrets-list

List user secrets.

Examples:

     $ reana-client secrets-list
