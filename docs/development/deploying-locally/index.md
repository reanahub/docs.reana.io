# Deploying locally

REANA can be easily deployed locally on your laptop using _Kubernetes in Docker_ ([kind](https://kind.sigs.k8s.io/)).
Useful for REANA platform development.

## Instructions

**1.** [Fork the REANA main repository](https://github.com/reanahub/reana/fork) and clone it to install `reana-dev` helper script:

```console
$ git clone git clone git@github.com:johndoe/reana
$ cd reana
$ virtualenv ~/.virtualenvs/reana
$ source ~/.virtualenvs/reana/bin/activate
(reana) $ pip install . --upgrade
```

**2.** Fork and clone all REANA cluster components repositories:

```console
(reana) $ reana-dev git-fork -c ALL
(reana) $ eval "$(reana-dev git-fork -c ALL)"
(reana) $ reana-dev git-clone -c ALL -u johndoe
```

**3.** Create a new REANA cluster:

```console
(reana) $ reana-dev cluster-create
```

**4.** Build all components:

```console
(reana) $ reana-dev cluster-build
```

**5.** Deploy REANA:

```console
(reana) $ reana-dev cluster-deploy --admin-email john.doe@example.org --admin-password 123456
```

**6.** Run an example:

```console
(reana) $ reana-dev run-example -c reana-demo-helloworld
```

## Examples

REANA can be deployed in development mode with code reload and [debugging capabilities](../debugging):

```console
(reana) $ reana-dev cluster-create --mode debug
(reana) $ reana-dev cluster-build --mode debug
(reana) $ reana-dev cluster-deploy --mode debug
```

Also, you can build and deploy REANA without the UI component:

```console
(reana) $ reana-dev cluster-build --exclude-components=r-ui
(reana) $ reana-dev cluster-deploy
```
