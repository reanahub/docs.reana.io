# Configuring workspaces

REANA configuration allows administrators to define new workspaces, in
which the workflow can run. The users can then state the desired workspace
in the `reana.yaml` file.  

If you would like to configure this additional workspaces, you can configure
[`workspaces.paths`](https://github.com/reanahub/reana/tree/master/helm/reana) Helm value
to the desired list of workspaces, consisting of strings as `hostPath:mountPath`.

Under this configuration, the first workspace listed will be the default
workspace path.

The [`shared_storage.shared_volume_mount_path`](https://github.com/reanahub/reana/tree/master/helm/reana) Helm value
is also an accepted workspace.
