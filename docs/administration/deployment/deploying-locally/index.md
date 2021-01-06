# Deploying locally

## For researchers

If you are a researcher and would like to try out deploying a small REANA cluster on your laptop, you can proceed as follows.

**1.** Install `docker`, `kubectl`, `kind`, and `helm` dependencies:

```console
$ firefox https://docs.docker.com/engine/install/
$ firefox https://kubernetes.io/docs/tasks/tools/install-kubectl/
$ firefox https://kind.sigs.k8s.io/docs/user/quick-start/
$ firefox https://helm.sh/docs/intro/install/
```

**2.** Deploy REANA cluster:

```console
$ wget https://raw.githubusercontent.com/reanahub/reana/maint-0.7/etc/kind-localhost-30443.yaml
$ kind create cluster --config kind-localhost-30443.yaml
$ wget https://raw.githubusercontent.com/reanahub/reana/maint-0.7/scripts/prefetch-images.sh
$ sh prefetch-images.sh
$ helm repo add reanahub https://reanahub.github.io/reana
$ helm repo update
$ helm install reana reanahub/reana --namespace reana --create-namespace --wait
```

**3.** Create REANA admin user:

```console
$ wget https://raw.githubusercontent.com/reanahub/reana/maint-0.7/scripts/create-admin-user.sh
$ sh create-admin-user.sh reana reana john.doe@example.org mysecretpassword
```

**4.** Log into your REANA instance:

```console
$ firefox https://localhost:30443
```

**5.** Follow instructions displayed on the web page to run your first REANA analysis example.

## For developers

If you are a developer and would like to work with REANA cluster source code, you can proceed as follows.

Set up virtual environment and install `reana-dev` helper script:

```console
$ mkdir ~/src && cd ~/src
$ virtualenv ~/.virtualenvs/reana
$ source ~/.virtualenvs/reana/bin/activate
(reana) $ pip install git+git://github.com/reanahub/reana.git#egg=reana
```

Fork and clone all REANA source code repositories:

```console
(reana) $ reana-dev git-fork --help
(reana) $ eval "$(reana-dev git-fork -c ALL)"
(reana) $ reana-dev git-clone -c ALL -u johndoe
```

Create a new REANA cluster:

```console
(reana) $ reana-dev cluster-create
```

Build all components:

```console
(reana) $ reana-dev cluster-build
```

Deploy REANA:

```console
(reana) $ reana-dev cluster-deploy \
            --admin-email john.doe@example.org \
            --admin-password mysecretpassword
```

Run an example:

```console
(reana) $ reana-dev run-example -c reana-demo-helloworld
```
