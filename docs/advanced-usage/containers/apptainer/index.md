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
| Kubernetes | Unavailable | Docker or OCI images executed by the Kubernetes container runtime |
| HTCondor | Opt-in | Unpacked container images from CVMFS selected with `unpacked_img: true`; regular registry images use Docker execution by default |
| Slurm | Always | Docker or OCI images converted to SIF, SIF files uploaded to the workspace, and unpacked container images from CVMFS |

The `unpacked_img` workflow hint is specific to HTCondor job execution. It has
no effect on Kubernetes or Slurm. Slurm always uses Apptainer and recognises SIF
files and CVMFS paths without this hint.

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
from a `/cvmfs` path; without the hint it treats `container` as a Docker image
reference and the HTCondor execution machine tries to pull it from a registry.

The hint changes how REANA launches the job; it does not resolve or download
the image. The chosen directory must already be available on the HTCondor
execution machine. See the [CernVM-FS container image documentation](https://cvmfs.readthedocs.io/en/latest/cpt-containers/#using-unpackedcernch)
for information about images distributed below `/cvmfs/unpacked.cern.ch/` and
how to request new ones through the
[CERN image wishlist](https://gitlab.cern.ch/unpacked/sync/-/blob/master/recipe.yaml).

See the [HTCondor compute backend](../../compute-backends/htcondor/index.md#choosing-container-execution-mode)
documentation for a Serial workflow example and more information about the two
execution modes.
