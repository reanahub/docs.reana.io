# Deploying locally

REANA can be easily deployed locally on your laptop using Minikube.  Useful for REANA platform development.

### Instructions

**1.** [Fork the REANA main repository](https://github.com/reanahub/reana/fork) and clone it to install `reana-dev` helper script:

```console
$ git clone git clone git@github.com:johndoe/reana
$ cd reana
$ virtualenv ~/.virtualenvs/reana
$ source ~/.virtualenvs/reana/bin/activate
(reana) $pip install . --upgrade
```

**2.** Fork and clone all REANA cluster components repositories:

```console
(reana) $ reana-dev git-fork -c ALL
(reana) $ # read and run the printed eval
(reana) $ GITHUB_USER=johndoe make clone
```

**3.** Start Minikube and prefetch base docker images:
```console
(reana) $ make setup prefetch
```

**4.** Build all components:
```console
(reana) $ make build
```


**5.** Deploy REANA:
```console
(reana) $ make deploy
```

**6.** Run an example:
```console
(reana) $ DEMO=reana-demo-helloworld make example
```

### Makefile variables reference

| Variable              | Description                                                                                         | Default value  |
|-----------------------|-----------------------------------------------------------------------------------------------------|----------------|
| `CLUSTER_FLAGS`       | Which [values](https://github.com/reanahub/reana/blob/master/helm/reana/README.md) need to be passed to `helm install`? (e.g. `debug.enabled=true,ui.enable=true`) | - |
| `DEMO`                | Which [demo example](https://github.com/reanahub?q=reana-demo) to run? (e.g. [`reana-demo-helloworld`](https://github.com/reanahub/reana-demo-helloworld)) | several |
| `EXCLUDE_COMPONENTS`  | Which REANA components should be excluded from the build? [e.g. `reana-ui,r-m-broker`]                | -              |
| `GITHUB_USER`         | Which GitHub user account to use for cloning the REANA repositories?                               | `anonymous`    |
| `INSTANCE_NAME`       | Which name/prefix to use for your REANA instance?                                                   | `reana`        |
| `MINIKUBE_CPUS`       | How many CPUs to allocate for Minikube?                                                             | `2`            |
| `MINIKUBE_DISKSIZE`   | How much disk size to allocate for Minikube?                                                        | `40g`          |
| `MINIKUBE_DRIVER`     | Which [VM driver](https://minikube.sigs.k8s.io/docs/reference/drivers/) to use for Minikube?        | `virtualbox`   |
| `MINIKUBE_KUBERNETES` | Which [Kubernetes version](https://github.com/kubernetes/kubernetes/releases) to use with Minikube? | `v1.16.3`      |
| `MINIKUBE_MEMORY`     | How much memory to allocate for Minikube?                                                           | `3072`         |
| `SERVER_URL`          | Setting a customized REANA Server hostname? (e.g. `https://example.org`)                            | https://[`` `minikube ip` ``](https://minikube.sigs.k8s.io/docs/reference/commands/ip/) |
| `TIMECHECK`           | Checking frequency in seconds when bringing cluster up and down?                                    | `5`            |
| `TIMEOUT`             | Maximum timeout to wait when bringing cluster up and down?                                          | `300`          |

## Examples

REANA can be deployed in development mode with code reload and [debugging capabilities](../debugging):
```console
(reana) $ CLUSTER_FLAGS="debug.enabled=true" make deploy
```

Also, you can build and deploy REANA without the UI component:
```console
(reana) $ EXCLUDE_COMPONENTS=r-ui,r-m-broker make build deploy
```
