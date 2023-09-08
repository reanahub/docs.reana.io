# Private Docker registries

If your workflow jobs use container images from private Docker registries, you
will need to grant access to the REANA platform to pull these images during run
time. The exact technique varies depending on the Docker registry. Please
follow the instructions below.

## CERN GitLab

Go to the _Project members_ tab of your CERN GitLab repository web interface
(`https://gitlab.cern.ch/johndoe/myanalysis/-/project-members`) and add the
[reana](https://gitlab.cern.ch/reana) service account as a collaborator with
the "Reporter" role:

![gitlab-authorize-reana](../../../images/gitlab-private-docker-registry.png)

This will ensure that the REANA platform will be able to access your private
repositories and pull your images.

In order to know more about the GitLab project collaborator roles, please see
the GitLab documentation on [project members
permissions](https://docs.gitlab.com/ee/user/permissions.html#project-members-permissions).
