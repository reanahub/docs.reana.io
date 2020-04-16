# Releasing

## Helm Charts

### 1. Build and test locally:

```console
$ DEMO=r-d-r-roofit EXCLUDE_COMPONENTS=r-ui,r-m-broker make ci
```

### 2. Build and test using the images to be released:

```yaml
$ BUILD_TYPE=release make ci
```

### 3. Upgrade chart version and commit:

If everything goes well you will see that the REANA components images in `helm/reana/values.yaml` are updated. Now you can upgrade the version in the `helm/reana/Chart.yaml` file, push your changes and create a pull request.

```diff
$ git diff helm/reana/Chart.yaml
-version: 0.7.0-dev20200416
+version: 0.7.0
$ git commit
```

!!! info
    The release will be created and added to the [REANA releases](https://github.com/reanahub/reana/releases) once the pull request is merged using the GitHub action [Helm Chart Releaser](https://github.com/marketplace/actions/helm-chart-releaser) in [`helm-releaser.yaml`](https://github.com/reanahub/reana/blob/master/.github/workflows/helm-releaser.yaml).

### 4. Push the images to DockerHub

```console
$ reana-dev docker-push -t auto -u reanahub
```
