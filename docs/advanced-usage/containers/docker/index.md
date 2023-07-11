# Docker

## Using an existing environment

In order to run your analysis, you can use a pre-existing container environment created by a third party. For example [`python:3.8`](https://hub.docker.com/_/python) for Python programs or [`gitlab-registry.cern.ch/cms-cloud/cmssw-docker/cc7-cms`](https://gitlab.cern.ch/cms-cloud/cmssw-docker/container_registry) for CMS Offline Software framework. In this case you simply specify the container name and the version number in your workflow specification and you are good to go. This is usually the case when your code does not have to be compiled, for example Python scripts or ROOT macros.

Note also that REANA offers a set of containers that can serve as examples about how to containerise popular analysis environments such as:

- ROOT (see [reana-env-root6](https://github.com/reanahub/reana-env-root6))
- Jupyter (see [reana-env-jupyter](https://github.com/reanahub/reana-env-jupyter))
- AliPhysics (see [reana-env-aliphysics](https://github.com/reanahub/reana-env-aliphysics))
- RucioClient (see [reana-env-rucioclient](https://github.com/reanahub/reana-env-rucioclient))

## Building your own environment

Other times you may need to build your own container, for example to add a certain library on top of Python 2.7. This is the most typical use case that we’ll address below.

This is usually the case when your code needs to be compiled, for example C++ analysis.

If you need to create your own environment, this can be achieved by means of providing a particular `Dockerfile`:

```{ .Dockerfile .copy-to-clipboard }
# Start from the Python 2.7 base image:
FROM docker.io/library/python:2.7

# Install HFtools:
RUN apt-get -y update && \
    apt-get -y install \
       python-pip \
       zip && \
    apt-get autoremove -y && \
    apt-get clean -y
RUN pip install hftools

# Mount our code:
ADD code /code
WORKDIR /code
```

You can build this customised analysis environment image and give it some name, for example `docker.io/johndoe/myenv`:

```{ .console .copy-to-clipboard }
$ docker build -f environment/myenv/Dockerfile -t docker.io/johndoe/myenv:1.0 .
```

and push the created image to the DockerHub image registry:

```{ .console .copy-to-clipboard }
$ docker push docker.io/johndoe/myenv:1.0
```

## Providing necessary shell

The Docker images for executing user jobs in the REANA ecosystem need to
contain `bash` shell in the image.

The `bash` shell is used in operational procedures to pass along
encoded/decoded job commands and parameters between REANA workflow
orchestration components, the job execution components and the compute backend
itself, so that the job execution behaviour would be consistent across
Kubernetes, HTCondor, Slurm backends for both Docker and Singularity execution
wrappers.

Therefore, please make sure that your Docker images contain the `bash` shell
executable, even if it may not be the default shell.

For example, if you would like to use the tiny Alpine image, which uses `ash`
shell by default, you can add a command in your `Dockerfile` to install
additional `bash` shell as follows:

```{ .Dockerfile .copy-to-clipboard }
FROM docker.io/library/alpine:3.17
RUN apk add bash
```

The `bash` shell is relatively widespread, so it is very probable that your
base images contain it already. Note that it is not necessary for `bash` to be
the default shell; only its presence is required. Please get in touch if this
requirement causes any trouble and you cannot ensure the presence of `bash` in
your job images.

## Supporting arbitrary user IDs

In the Docker container ecosystem, the processes run in the containers by default, uses the root user identity. However, this may not be secure. If you want to improve the security in your environment you can set up your own user under which identity the processes will run.

In order for processes to run under any user identity and still be able to write to shared workspaces, we use a GID=0 technique [as used by OpenShift](https://docs.openshift.com/container-platform/3.11/creating_images/guidelines.html#openshift-specific-guidelines):

- UID: you can use any user ID you want;
- GID: your should add your user to group with GID=0 (the root group)

This will ensure the writable access to workspace directories managed by the REANA platform.

For example, you can create the user `johndoe` with `UID=501` and add the user to `GID=0` by adding the following commands at the end of the previous `Dockerfile`:

```{ .Dockerfile .copy-to-clipboard }
# Setup user and permissions
RUN adduser johndoe -u 501 --disabled-password --gecos ""
RUN usermod -a -G 0 johndoe
USER johndoe
```

## Testing the environment

We now have a containerised image representing our computational environment that we can use to run our analysis in another replicated environment.

We should test the containerised environment to ensure it works properly, for example whether all the necessary libraries are present:

```console
$ docker run -i -t --rm docker.io/johndoe/myenv /bin/bash
container> python -V
Python 2.7.15
container> python mycode.py < mydata.csv > /tmp/mydata.tmp
```

## Multiple environments

Note that various steps of your analysis can run in various environments; for instance, the step to perform the data filtering on a big cloud, having data selection libraries installed, or the step to build the data plotting in a local environment, containing only the preferred graphing system of choice. You can prepare several different environments for your analysis if needed.
