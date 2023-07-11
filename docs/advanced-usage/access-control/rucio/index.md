# Rucio

## About Rucio

[Rucio](https://rucio.cern.ch/) is a scientific data management system used in
LHC particle physics and related scientific domains. It provides access for
large volumes of data spread across facilities at multiple institutions.

If your workflow needs to access some researched data managed by a Rucio
instance, you can use the Rucio authentication technique described below.

## Dependencies

Currently, the Rucio authentication technique relies on the VOMS proxy
authentication, meaning that you must set up your VO user certificates and
proxy. Please see the [VOMS proxy documentation page](../voms-proxy/) for more
information.

## Uploading secrets

In order to create the Rucio configuration for your workflow jobs, you will
have to upload your [VOMS proxy secrets](../voms-proxy/#uploading-secrets) as
well as your Rucio username, for example:

```console
$ reana-client secrets-add --env VONAME=atlas \
                           --env VOMSPROXY_FILE=x509up_u1000 \
                           --file /tmp/x509up_u1000 \
                           --env RUCIO_USERNAME=johndoe
```

## Configuring your workflows

You are now ready to declare that some steps of your workflow need to access
Rucio data. This can be achieved by setting the workflow hints `voms_proxy` and
`rucio` for those steps. The examples below show how to specify this hint for
your CWL, Serial, Snakemake and Yadage workflows.

CWL workflow example:

```yaml hl_lines="3 4 5 6"
steps:
  first:
    hints:
      reana:
        voms_proxy: true
        rucio: true
    run: rucio get my_rucio_scope:my_rucio_file
```

Serial workflow example:

```yaml hl_lines="6 7"
workflow:
  type: serial
  specification:
    steps:
      - environment: docker.io/reanahub/reana-auth-rucio:1.0.0
        voms_proxy: true
        rucio: true
        commands:
          - rucio get my_rucio_scope:my_rucio_file
```

Snakemake example:

```yaml hl_lines="4 5 6"
rule mystep:
  container:
    "docker://docker.io/reanahub/reana-auth-rucio:1.0.0"
  resources:
    voms_proxy=True,
    rucio=True
  shell:
    "rucio get my_rucio_scope:my_rucio_file"
```

Yadage example:

```yaml hl_lines="13 14 15"
step:
  process:
    process_type: "string-interpolated-cmd"
    cmd: 'rucio get my_rucio_scope:my_rucio_file'
  publisher:
    publisher_type: "frompar-pub"
    outputmap:
      outputfile: outputfile
  environment:
    environment_type: "docker-encapsulated"
    image: "docker.io/reanahub/reana-auth-rucio"
    imagetag: "1.0.0"
    resources:
      - voms_proxy: true
      - rucio: true
```

The `voms_proxy` and `rucio` workflow hints are fully sufficient to instruct
REANA to set up the Rucio configuration for your jobs. You don't have to modify
the logic of your workflow steps in any other way besides providing the above
one-line workflow hint declarations.

## Creating your job environment images

In the above examples, we have used the `reana-auth-rucio:1.0.0` as an
example of a job environment container image that can be used at runtime to
access some Rucio-managed data files. When REANA will orchestrate the execution
of this job, it will automatically create a sidecar container that will perform
the necessary Rucio configuration beforehand, using the secrets you uploaded.
The environment image of your choice must simply contain the `rucio-clients`
package installed.
