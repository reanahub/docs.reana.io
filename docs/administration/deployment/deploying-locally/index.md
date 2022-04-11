# Deploying locally

## For researchers

If you are a researcher and would like to try out deploying a small REANA cluster on your laptop,
you can proceed as follows.

**1.** Install `docker`, `kubectl`, `kind`, and `helm` dependencies:

```{ .console .copy-to-clipboard }
$ firefox https://docs.docker.com/engine/install/
$ firefox https://kubernetes.io/docs/tasks/tools/install-kubectl/
$ firefox https://kind.sigs.k8s.io/docs/user/quick-start/
$ firefox https://helm.sh/docs/intro/install/
```

**2.** Deploy REANA cluster:

```{ .console .copy-to-clipboard }
$ wget https://raw.githubusercontent.com/reanahub/reana/maint-0.8/etc/kind-localhost-30443.yaml
$ kind create cluster --config kind-localhost-30443.yaml
$ wget https://raw.githubusercontent.com/reanahub/reana/maint-0.8/scripts/prefetch-images.sh
$ sh prefetch-images.sh
$ helm repo add reanahub https://reanahub.github.io/reana
$ helm repo update
$ helm install reana reanahub/reana --namespace reana --create-namespace --wait
```

**3.** Create REANA admin user:

```{ .console .copy-to-clipboard }
$ wget https://raw.githubusercontent.com/reanahub/reana/maint-0.8/scripts/create-admin-user.sh
$ sh create-admin-user.sh reana reana john.doe@example.org mysecretpassword
```

**4.** Log into your REANA instance:

```{ .console .copy-to-clipboard }
$ firefox https://localhost:30443
```

**5.** Follow instructions displayed on the web page to run your first REANA analysis example.

## For developers

If you are a developer and would like to install REANA locally and contribute to the REANA cluster code,
please see the [REANA wiki on GitHub](https://github.com/reanahub/reana/wiki).
