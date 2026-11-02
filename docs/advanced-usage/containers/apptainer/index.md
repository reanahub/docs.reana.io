# Apptainer

[Apptainer](https://apptainer.org/), formerly known as Singularity, is a
container runtime commonly used in scientific high-throughput and
high-performance computing environments. REANA uses it on batch compute
backends where the runtime and the requested image are available. The
executable on the compute node may still be called `singularity`.

## Compute backend support

The available execution modes depend on the compute backend:

| Compute backend | REANA Apptainer execution | Supported environments |
| --- | --- | --- |
| Kubernetes | Opt-in by the administrator | Unpacked container images from CVMFS and SIF files uploaded to the workspace; regular registry images use the Kubernetes container runtime |
| HTCondor | Opt-in | Unpacked container images from CVMFS selected with `unpacked_img: true`; regular registry images use Docker execution by default |
| Slurm | Always | Docker or OCI images converted to SIF, SIF files uploaded to the workspace, and unpacked container images from CVMFS |

The `unpacked_img` workflow hint is specific to HTCondor job execution. It has
no effect on Kubernetes or Slurm. Kubernetes and Slurm recognise SIF files and
CVMFS paths without this hint.

CVMFS is automatically available for HTCondor and Slurm jobs, so no
`resources.cvmfs` clause is needed. Kubernetes jobs mount the CVMFS repository
of their own image automatically. Other repositories still need the
`resources.cvmfs` clause. See the
[CVMFS guide](../../code-repositories/cvmfs/index.md) for details.

## Kubernetes execution

When the cluster administrators enable it, a Kubernetes job can use an image
that REANA executes with Apptainer. Set the environment of the step to one of
these values:

- the directory of an unpacked container image on CVMFS, for example
  `/cvmfs/unpacked.cern.ch/registry.hub.docker.com/library/python:3.12`;
- a SIF file that you upload with the workflow, for example
  `my-image.sif`. A relative path starts at the workflow workspace.

For example, a serial workflow can use a SIF file as follows:

```yaml hl_lines="4 8"
inputs:
  files:
    - code/analysis.py
    - my-image.sif
workflow:
  type: serial
  specification:
    steps:
      - environment: my-image.sif
        commands:
          - python code/analysis.py
```

The pod of the job starts an Apptainer runner container, which executes the
step command inside your image. Please note the following points:

- The image must contain `bash`.
- The workspace, file secrets, Kerberos, VOMS and Rucio credentials, EOS and
  CVMFS repositories are available inside the image at the same paths as in
  a regular Kubernetes job.
- Each job extracts its SIF image into `/tmp` before the command starts. This
  takes time and local disk space for each job. If the cluster uses a
  read-only root filesystem for jobs, the extracted image counts against the
  size limit of the job scratch space, and a large image can cause the
  eviction of the job. Use an unpacked image from CVMFS for large images.

### Administrator setup

Apptainer execution on Kubernetes is disabled by default. REANA refuses the
jobs that use a CVMFS path or a SIF file as image, with an error message. To
enable it, set the following Helm value:

```yaml
components:
  reana_job_controller:
    environment:
      REANA_KUBERNETES_JOBS_APPTAINER_ENABLED: "true"
```

Before you enable it, check these requirements:

- Apptainer creates an unprivileged user namespace and mounts the image in it.
  For this, REANA runs these jobs with the `Unconfined` seccomp and AppArmor
  profiles. The job container still runs as the non-root job user, without
  capabilities and without privilege escalation. The Baseline and Restricted
  Pod Security Standards do not allow these profiles, so a namespace that
  enforces them rejects the job pods.
- The cluster must run Kubernetes 1.30 or later, which supports the AppArmor
  profile field.
- The nodes must allow unprivileged user namespaces. For example, Ubuntu 24.04
  restricts them with `kernel.apparmor_restrict_unprivileged_userns=1`. Such
  nodes need an AppArmor policy that allows the user namespaces of these jobs.
- CVMFS images need the CVMFS CSI driver, as for the `resources.cvmfs` clause.
- With vetted container images (the `vetted_container_images` Helm value),
  REANA accepts only SIF files on CVMFS, because users can change the content
  of other SIF files. Add CVMFS paths of SIF files or unpacked images to the
  allowlist.

You can change the runner with these job controller environment variables:

| Variable | Default | Description |
| --- | --- | --- |
| `REANA_UNPACKED_IMAGE_RUNNER` | `ghcr.io/apptainer/apptainer:1.4.5` | Image of the runner container |
| `REANA_UNPACKED_IMAGE_RUNNER_COMMAND` | `apptainer` | Command that executes the image, for example `singularity` |

A replacement runner image must contain `sh`, `cp`, `id`, `getent`, `mktemp`,
`mkdir`, `awk`, `base64` and `unsquashfs`, and its runner command must support
the `exec` and `sif list` subcommands.

## Slurm execution

REANA executes all Slurm jobs with Apptainer. A workflow step can use a regular
Docker or OCI image reference, which REANA converts to SIF before submitting the
job. It can also use a SIF file uploaded to the workflow workspace or an
unpacked image available on CVMFS.

See the [Slurm compute backend](../../compute-backends/slurm/index.md#specifying-environment)
documentation for image caching details and workflow examples.

## Unpacked images on HTCondor

The CERN HTCondor backend normally executes regular Docker or OCI images from a
container registry. To execute an unpacked image from CVMFS with Apptainer
instead, set the workflow step's environment to its CVMFS directory and enable
the `unpacked_img` hint.

For example, a Snakemake rule can use the unpacked Python 3.10 image as follows:

```python hl_lines="5 6 8"
rule python_version:
    output:
        "python-version.txt"
    resources:
        compute_backend="htcondorcern",
        unpacked_img=True
    container:
        "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/library/python:3.10"
    shell:
        "python --version > {output}"
```

Serial workflows set `unpacked_img` directly on the step, as shown in the
[HTCondor example](../../compute-backends/htcondor/index.md#apptainer-with-cvmfs-unpacked-images).
CWL and Yadage workflows support the same option: place it alongside
`compute_backend` in the step's REANA hints for CWL or environment resources
for Yadage.

The `unpacked_img` hint is required. REANA does not infer the execution mode
from a `/cvmfs` path; without the hint it treats the environment as a Docker
image reference and the HTCondor execution machine tries to pull it from a
registry.

The hint changes how REANA launches the job; it does not resolve or download
the image. The chosen directory must already be available on the HTCondor
execution machine. See the [CernVM-FS container image documentation](https://cvmfs.readthedocs.io/en/latest/cpt-containers/#using-unpackedcernch)
for information about images distributed below `/cvmfs/unpacked.cern.ch/` and
how to request new ones through the
[CERN image wishlist](https://gitlab.cern.ch/unpacked/sync/-/blob/master/recipe.yaml).

See the [HTCondor compute backend](../../compute-backends/htcondor/index.md#choosing-container-execution-mode)
documentation for a Serial workflow example and more information about the two
execution modes.
