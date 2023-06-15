# Configuring private Docker registries

REANA is able to execute workflows which make use of Docker images hosted on private Docker image registries.
You will just need to save the necessary credentials in Kubernetes secrets, and then instruct REANA to pass these secrets to each job's pod.

## Obtaining the credentials

First of all, you will need to obtain the authentication credentials, and how to do so varies depending on which registry you are using.
One possibility would be to create a special service account to access the registry.
As an example, the [REANA service account](https://gitlab.cern.ch/reana) is used to authenticate to the private registry provided by CERN's GitLab instance, as shown in [Private Docker registries](../../../advanced-usage/access-control/private-docker-registries/#cern-gitlab).

## Configuring Kubernetes and REANA

After obtaining the credentials, you will have to save them in a Kubernetes secret, as explained in the related Kubernetes documentation page [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).
In particular, this is how you would create the secret from an already existing Docker configuration file, after running `docker login`:

```{ .console .copy-to-clipboard }
$ kubectl create secret generic my-cern-gitlab-secret \
    --from-file=".dockerconfigjson=$HOME/.docker/config.json" \
    --type="kubernetes.io/dockerconfigjson"
```

As an alternative, you can create the secret by providing the username and password needed to authenticate to the private registry:

```{ .console .copy-to-clipboard }
$ kubectl create secret docker-registry my-cern-gitlab-secret \
    --docker-server="https://gitlab-registry.cern.ch" \
    --docker-username="johndoe" \
    --docker-password="mysecretpassword" \
    --docker-email="john.doe@example.org"
```

You should then set the [`components.reana_workflow_controller.environment.IMAGE_PULL_SECRETS`](https://github.com/reanahub/reana/tree/master/helm/reana) Helm value to the name of the secret, which in the above examples is `my-cern-gitlab-secret`:

```yaml
components:
  reana_workflow_controller:
    environment:
      IMAGE_PULL_SECRETS: "my-cern-gitlab-secret"
```

If you would like to configure multiple private Docker registries, you should create one secret for each of them, for example `my-cern-gitlab-secret` for CERN GitLab and `my-ghcr-secret` for GitHub Container Registry. Then, you have to specify all the secrets in the `components.reana_workflow_controller.environment.IMAGE_PULL_SECRETS` Helm value, separating the names with commas:

```yaml
components:
  reana_workflow_controller:
    environment:
      IMAGE_PULL_SECRETS: "my-cern-gitlab-secret,my-ghcr-secret"
```
