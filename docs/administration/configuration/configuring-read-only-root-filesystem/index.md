# Configuring read-only root filesystem

By default, a user container in REANA can write to all directories of its own
container image. These writes go to the local disk of the cluster node. They do
not count towards the user disk quota, and they disappear when the pod stops.

REANA can mount the root filesystem of user containers as read-only. The
container image then cannot change at run time. This is a common requirement of
Kubernetes security policies.

## Enabling read-only root filesystem

The read-only root filesystem is disabled by default. To enable it, set the
[`kubernetes_jobs_read_only_root_filesystem`](https://github.com/reanahub/reana/tree/master/helm/reana)
Helm value:

```yaml
kubernetes_jobs_read_only_root_filesystem: true
```

The option applies to these containers:

- the workflow engine container of each workflow run;
- the user job containers on the Kubernetes compute backend;
- the interactive session containers;
- the Dask scheduler and Dask worker containers.

The option does not apply to the job controller container, to the Kerberos,
VOMS and Rucio helper containers, or to jobs that run on the HTCondor and Slurm
compute backends. These REANA containers keep a writable root filesystem.

!!! note

    A Kubernetes admission policy that requires a read-only root filesystem on
    every container still refuses the workflow pods, because of the job
    controller container. If the policy also checks init containers, it also
    refuses the pods that use the Kerberos, VOMS or Rucio helpers. Add an
    exception for these pods to such a policy.

## Writable locations

When the option is enabled, a container can write only to these locations:

| Location                                                        | Storage                       | Lifetime                   |
| --------------------------------------------------------------- | ----------------------------- | -------------------------- |
| The workflow workspace                                          | Shared storage volume         | Same as the workspace      |
| `/tmp`                                                          | Scratch volume on the node    | Deleted when the pod stops |
| `/.cache` (jobs, workflow engines, Dask pods)                   | Scratch volume on the node    | Deleted when the pod stops |
| `/home/reana` (interactive sessions)                            | Scratch volume on the node    | Deleted when the pod stops |
| `/krb5_cache`, `/vomsproxy_cache`, `/rucio_cache` (credentials) | Credential volume on the node | Deleted when the pod stops |
| `/eos` (only when EOS is available)                             | EOS storage                   | Same as the EOS files      |

A host-path mount can replace the scratch volume at `/tmp` or `/.cache`. This
location is then read-only, unless the mount sets `"readOnly": false`. See
[Host-path mounts](#host-path-mounts).

The scratch volumes are Kubernetes `emptyDir` volumes. Each pod has its own
scratch volumes, and other pods cannot read them. The data on a scratch volume
does not count towards the user disk quota.

A pod has the credential volumes only when the workflow uses Kerberos, VOMS or
Rucio. They hold the credential files of the user. Each credential volume has a
fixed size limit of 10 MiB, so that it cannot be used as extra scratch space.

Host-path mounts that you declare as writable also stay writable. See the
[Host-path mounts](#host-path-mounts) section below.

Two more locations stay writable, because Kubernetes gives them to each
container:

- `/dev/shm` is a memory-backed directory with a size of 64 MiB. The data
  there counts towards the memory limit of the container.
- `/dev/termination-log` is one file on the local disk of the node. Kubernetes
  reads the reason for a container failure from it. The scratch volume size
  limit does not apply to this file, so monitor the free disk space of your
  nodes.

In an interactive session, REANA sets the `HOME` environment variable to
`/home/reana`. Jupyter, IPython and `pip install --user` keep their files
there. These files are lost when the user closes the session. Notebooks and
data that the user wants to keep must be in the workspace.

REANA mounts `/.cache` but does not change the `HOME` environment variable of
jobs. A tool that keeps its cache in `$HOME/.cache` can use `/.cache` only if
`HOME` is `/`. Users can set `XDG_CACHE_HOME=/.cache` or `HOME=/tmp` in the
environment of their workflow steps.

## Limiting the size of scratch volumes

A scratch volume uses the local disk of the cluster node. To prevent that one
pod fills this disk, each scratch volume has a size limit. The default limit is
`5Gi`. You can change it with the
[`kubernetes_jobs_scratch_volume_size_limit`](https://github.com/reanahub/reana/tree/master/helm/reana)
Helm value:

```yaml
kubernetes_jobs_read_only_root_filesystem: true
kubernetes_jobs_scratch_volume_size_limit: 10Gi
```

The limit applies to each scratch volume of each pod separately. A pod with two
scratch volumes can thus write two times the limit.

The limit is not a hard quota. Kubernetes measures the usage of each volume
periodically, and it evicts the pod when the usage is more than the limit. A
pod can write more data than the limit before Kubernetes measures it. The limit
thus decreases the risk that one pod fills the local disk of its node, but it
does not prevent it. Make sure that the nodes have sufficient local disk for
the number of pods that run on one node at the same time, and monitor the free
disk space of the nodes. See the
[Kubernetes documentation on local ephemeral storage](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#local-ephemeral-storage)
for more information.

The result of an eviction depends on the type of pod:

- **Job:** the job fails. The job logs tell the user that the job wrote too
  much data to its scratch space.
- **Interactive session:** Kubernetes starts a new session pod with an empty
  home directory. The user loses the connection to the session and the
  packages installed with `pip install --user`. Note that the `pip` cache is
  also in the home directory.
- **Dask worker:** Kubernetes starts a new worker, and Dask can run the task
  again. A Dask worker can write more data to `/tmp` than its memory size when
  it moves data from memory to disk. Select a limit that is larger than the
  memory of the Dask workers, or configure Dask to keep this data in the
  workspace.

For interactive sessions and Dask workers, the workflow logs show the reason
of the eviction. Kubernetes keeps this reason in an event for a limited time,
by default one hour (the `--event-ttl` option of the Kubernetes API server).
After this time, the logs can show only that the pod stopped.

Select a limit that agrees with the local disk size of your nodes and with the
number of pods that run on one node at the same time. To remove the limit, set
the value to an empty string. We do not recommend this, because one job can
then cause the eviction of the pods of other users on the same node.

## Host-path mounts

If you use the
[`REANA_JOB_HOSTPATH_MOUNTS`](https://github.com/reanahub/reana/tree/master/helm/reana)
environment variable to mount directories of the cluster nodes into user jobs,
each mount accepts an optional `readOnly` field. When the read-only root
filesystem is enabled, a mount without this field is read-only. To keep a mount
writable, set `readOnly` to `false`:

```yaml
components:
  reana_workflow_controller:
    environment:
      REANA_JOB_HOSTPATH_MOUNTS: |
        [
          {"name": "software", "hostPath": "/opt/software"},
          {"name": "scratch", "hostPath": "/mnt/scratch", "readOnly": false}
        ]
```

In this example, `/opt/software` is read-only and `/mnt/scratch` stays
writable.

A host-path mount with the `mountPath` `/tmp` or `/.cache` replaces the scratch
volume at this path in user jobs and Dask workers. The scratch volume size limit
does not apply to a host-path mount. Such a mount also follows the read-only
default. Set `"readOnly": false` on it, otherwise `/tmp` or `/.cache` becomes
read-only in user jobs and Dask workers.

## Effect on user workflows

Software that writes to its workspace, to `/tmp` or to `/.cache` continues to
work, unless a read-only host-path mount replaces `/tmp` or `/.cache`. Software
that writes to other directories of its container image fails with a
`Read-only file system` error. Typical examples are:

- a job that installs packages into the container image at run time;
- a tool that writes configuration or history files to a home directory that
  is part of the container image.
- a Yadage workflow step that writes files with relative paths. A Yadage step
  starts in the working directory of its container image, not in the
  workspace.

Users can frequently repair such a job without a new image. For example, a
job step can start with `export HOME=/tmp` or `cd /tmp`, or it can point the
tool to a directory in the workspace.

!!! warning

    Run your typical workflows and open an interactive session with each
    image that you offer to users before you enable this option on a
    production cluster. If an important workload cannot run with a read-only
    root filesystem, keep the option disabled.
