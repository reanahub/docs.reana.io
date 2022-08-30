# Rucio

## About Rucio

[Rucio](https://rucio.cern.ch/) is a project that provides services and associated
libraries for allowing scientific collaborations to manage large volumes of data
spread across facilities at multiple institutions and organisations. Rucio was
originally developed to meet the requirements of the high-energy physics experiment
ATLAS, and now is continuously extended to support the LHC experiments and other
diverse scientific communities.

Rucio offers advanced features, is highly scalable, and modular. It is a data
management solution that covers the needs of different communities in the scientific
domain (e.g., HEP, astronomy, biology).

If your workflow needs data access to a Rucio instance, you can use the Rucio
authentication technique with your REANA workflows as described in detail below.

## VOMS proxy dependency

Currently, Rucio requires VOMS authentication meaning that `voms_proxy: true`
has also to be declared.

## Uploading secrets

In order to create the Rucio configuration for your workflow jobs, REANA would
need the secrets required by VOMS proxy and your Rucio username.
In more detail, (i) user certificate `usercert.pem`, (ii) encrypted private
key `userkey.pem`, (iii) the Grid passphrase encoded using the base64
encoding, (iv) the VO you would like to use, such as
"atlas" or "cms", and (v) your Rucio username.

More details about VOMS proxy secrets can be found in the
[Uploading secrets](../voms-proxy) section of VOMS proxy page.

These five necessary secrets can be uploaded to REANA as follows:

```console
$ reana-client secrets-add --file userkey.pem \
                           --file usercert.pem \
                           --env VOMSPROXY_PASS=bXlncmlkcGFzc3BocmFzZQ== \
                           --env VONAME=cms \
                           --env RUCIO_USERNAME=rucio_username
```

## Configuring your workflows

You are now ready to declare that some steps of your workflow need to
access Rucio data. This can be achieved by setting the workflow hint
called `rucio` for those steps. The examples below show how to specify
this hint for your CWL, Serial, Snakemake and Yadage workflows.

CWL workflow example:

```yaml hl_lines="3 4 5"
steps:
  first:
    hints:
      reana:
        voms_proxy: true
        rucio: true
    run: rucio get my_rucio_scope:my_rucio_file
```

Serial workflow example:

```yaml hl_lines="6"
workflow:
  type: serial
  specification:
    steps:
      - environment: reana-env-rucioclient:1.0
        voms_proxy: true
        rucio: true
        commands:
          - rucio get my_rucio_scope:my_rucio_file
```

Snakemake example:

```yaml hl_lines="4 5"
rule mystep:
  container:
    "docker://reana-env-rucioclient:1.0"
  resources:
    voms_proxy=True
    rucio=True
  shell:
    "rucio get my_rucio_scope:my_rucio_file"
```

Yadage example:

```yaml hl_lines="13 14"
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
    image: "reana-env-rucioclient"
    imagetag: "1.0"
    resources:
      - voms_proxy: true
      - rucio: true
```

The `rucio` workflow hint is fully sufficient to instruct REANA to set up
the Rucio configuration  for your jobs. You don't have to modify the logic
of your workflow steps in any other way besides providing the above one-line
workflow hint declarations.

## Creating your job environment images

In the above examples, we have used `reana-env-rucioclient:1.0` as an
example of the job environment container image that would be used at runtime to
execute the workflow step that is accessing some Rucio files. When REANA will
orchestrate the execution of this job, it will automatically create a sidecar
container that will perform the necessary Rucio configuration beforehand, using
the secrets you uploaded. The environment image of your choice must have
rucio-clients installed.
