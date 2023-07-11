# Slurm

Slurm is a specialized workload management system for high performance
computing jobs and it is supported by REANA alongside primary job execution
backend Kubernetes and HTCondor.

## Authentication

In order to use the CERN Slurm cluster for your REANA jobs, you first need to
have access to the [CERN Slurm Linux HPC resource](https://batchdocs.web.cern.ch/linuxhpc/index.html).
Please find more information about how to get access there.

The authentication between REANA cluster and CERN Slurm compute backend happens
on the basis of Kerberos authentication. Please [generate your keytab](../../access-control/kerberos/index.md#generating-keytab-file)
and [upload your secrets](../../access-control/kerberos/index.md#uploading-secrets).

## Specifying compute backend

You can decide which steps of your workflows will be run on Kubernetes and which
steps will be dispatched to the CERN Slurm cluster by setting the `compute_backend`
workflow hint accordingly. Please use `slurmcern` if you would like to dispatch
some jobs to the CERN Slurm compute backend. You can consult the [Examples](.#examples)
section below about how to do this for your CWL, Serial, Snakemake, Yadage workflows.

## Specifying environment

The Slurm jobs will run in a containerised compute environment that uses
Singularity container technology. There are three possibilities how you can
specify the desired computing environment for your job:

- If you are using a Docker container image in your workflow step, REANA will
  automatically convert the image into a Singularity SIF image before submitting
  the job. This is fully transparent.
- You can also specify your own Singularity SIF image. You have to upload it into
  your workspace before starting the workflow.
- You can also use Singularity images from the [CVMFS unpacked images](https://gitlab.cern.ch/unpacked/sync/-/blob/master/recipe.yaml) area.

Please see the [Examples](.#examples) section below that will provide concrete
examples for each of these techniques.

## Specifying Slurm parameters

If you would like to specify a concrete Slurm partition to use or a concrete
Slurm timeout limit, you can provide additional workflow hints called
`slurm_partition` (default is `inf-short`) and `slurm_time` (default is 60 minutes).
The available Slurm partition values are listed in [CERN Linux HPC resources](https://batchdocs.web.cern.ch/linuxhpc/resources.html)
documentation page. Please see the [Examples](.#examples) section below for some
concrete examples.

## Examples

The following **CWL** workflow specification will dispatch the first `gendata`
step of the [RooFit demo example](https://github.com/reanahub/reana-demo-root6-roofit)
to the CERN Slurm compute backend, using a regular **Docker image** for the job environment:

```yaml hl_lines="6"
  ...
  steps:
    gendata:
      hints:
        reana:
          compute_backend: slurmcern
      run: gendata.cwl
      in:
        gendata_tool: gendata_tool
        events: events
      out: [data]
```

The following **Serial** workflow specification will dispatch the first `gendata`
step of the [RooFit demo example](https://github.com/reanahub/reana-demo-root6-roofit)
to the CERN Slurm compute backend, using a **custom Singularity image** called `myimage_1_0.sif` from the workspace:

```yaml hl_lines="5 9 10"
  ...
  inputs:
    files:
      ...
      - myimage_1_0.sif
  ...
  steps:
    - name: gendata
      environment: 'myimage_1_0.sif'
      compute_backend: slurmcern
      commands:
        - mkdir -p results && root -b -q 'code/gendata.C(${events},"${data}")'
```

The following **Snakemake** workflow specification will dispatch the first `gendata`
step of the [RooFit demo example](https://github.com/reanahub/reana-demo-root6-roofit)
to the CERN Slurm compute backend, using a particular **Singularity image from CVMFS unpacked image area**:

```yaml hl_lines="10 12"
  ...
  rule gendata:
      input:
          gendata_tool=config["gendata"]
      output:
          "results/data.root"
      params:
          events=config["events"]
      container:
          "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/rootproject/root:6.26.00-ubuntu20.04"
      resources:
          compute_backend="slurmcern"
      shell:
          "mkdir -p results && root -b -q '{input.gendata_tool}({params.events},\"{output}\")'"
```

The following **Yadage** workflow specification will dispatch the first `gendata`
step of the [RooFit demo example](https://github.com/reanahub/reana-demo-root6-roofit)
to the CERN Slurm compute backend, using a **custom Slurm partition** called `photon`
and a **custom Slurm timeout** of five minutes:

```yaml hl_lines="14 15 16"
  ...
  stages:
    - name: gendata
      dependencies: [init]
      scheduler:
        ...
        step:
          ...
          environment:
            environment_type: 'docker-encapsulated'
            image: 'docker.io/reanahub/reana-env-root6'
            imagetag: '6.18.04'
            resources:
              - compute_backend: slurmcern
              - slurm_partition: 'photon'
              - slurm_time: '5'
```
