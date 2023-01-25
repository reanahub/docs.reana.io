# Shared storage

REANA uses a shared filesystem for storing the results of your running workflows.
Each workflow run is assigned a unique workspace directory in the shared storage that the workflow jobs use to store any temporary results.
This constitutes the default workspace directory of the workflow run.
The workspace directory path is also stored in an automatically created environment variable `REANA_WORKSPACE` that you can use in your workflows.

The shared storage space is usually limited, so it is important to remove any temporary files as soon as they are not needed.
You can configure [workspace file retention rules](../../workspace-retention) to clean your workspace automatically.

If you would like to transfer files to/from shared storage, you can use the `reana-client upload` and `reana-client download` commands manually.
If you would like to publish the results of your workflow out of the internal shared storage into an external storage system, you can use the stage-in stage-out techniques as described for the [EOS](../eos) external storage backend.
