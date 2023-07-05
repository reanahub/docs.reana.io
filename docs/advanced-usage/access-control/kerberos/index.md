# Kerberos

If your workflow needs to access external services from within the job such as
EOS you could use Kerberos authentication.

## Generating keytab file

At CERN, you can connect to `lxplus7.cern.ch` to generate a Kerberos keytab
file for passwordless authentication in the following way:

```console
$ cern-get-keytab --keytab ~/.keytab --user --login johndoe
```

You can test the freshly generated keytab file as follows:

```console
$ kdestroy; kinit -kt ~/.keytab johndoe; klist
Ticket cache: FILE:/tmp/krb5cc_1234_5678
Default principal: johndoe@CERN.CH

Valid starting       Expires              Service principal
07/05/2023 18:04:13  07/06/2023 19:04:13  krbtgt/CERN.CH@CERN.CH
    renew until 07/10/2023 18:04:13
07/05/2023 18:04:13  07/06/2023 19:04:13  afs/cern.ch@CERN.CH
    renew until 07/10/2023 18:04:13
```

## Uploading secrets

Once you have a working keytab file, you need to upload your CERN username
and keytab secrets to REANA:

```{ .console .copy-to-clipboard }
$ reana-client secrets-add --env CERN_USER=johndoe \
                           --env CERN_KEYTAB=.keytab \
                           --file ~/.keytab
```

## Setting Kerberos requirement

### Setting Kerberos requirement for whole workflow

If the workflow engine you are using needs Kerberos to parse and validate the
workflow specification, then you can enable it globally for the whole workflow
orchestration in the `reana.yaml` file. For example, this may be needed if you
are using the Snakemake workflow engine with data objects living in a
restricted data storage:

```yaml hl_lines="4"
workflow:
  type: snakemake
  resources:
    kerberos: true
  file: workflow/snakemake/Snakefile
```

This will enable Kerberos authentication not only for workflow orchestration,
but also for each workflow step job.

### Setting Kerberos requirement for certain jobs only

If your workflow does not need Kerberos for the whole duration, but only for
some of its steps, you can provide a workflow hint `kerberos: true` for only
those steps that need it.

Serial example:

```yaml hl_lines="9"
workflow:
  type: serial
  resources:
    cvmfs:
      - fcc.cern.ch
  specification:
    steps:
      - environment: "cern/slc6-base"
        kerberos: true
        commands:
          - ls -l /cvmfs/fcc.cern.ch/sw/views/releases/
```

CWL example:

```yaml hl_lines="5"
steps:
  first:
    hints:
      reana:
        kerberos: true
    run: helloworld.tool
    in:
      helloworld: helloworld

      inputfile: inputfile
      sleeptime: sleeptime
      outputfile: outputfile
    out: [result]
```

Yadage example:

```yaml hl_lines="14"
step:
  process:
    process_type: "string-interpolated-cmd"
    cmd: 'python "{helloworld}" --sleeptime {sleeptime} --inputfile "{inputfile}" --outputfile "{outputfile}"'
  publisher:
    publisher_type: "frompar-pub"
    outputmap:
      outputfile: outputfile
  environment:
    environment_type: "docker-encapsulated"
    image: "python"
    imagetag: "2.7-slim"
    resources:
      - kerberos: true
```

Snakemake example:

```yaml hl_lines="10"
rule helloworld:
  input:
    helloworld=config["helloworld"],
    inputfile=config["inputfile"],
  params:
    sleeptime=config["sleeptime"]
  output:
    "results/greetings.txt"
  resources:
    kerberos=True
  container: "docker://python:2.7-slim"
```

> Please note that Kerberos token is automatically provided for HTCondor and
 Slurm compute backend jobs and there is no need to specify kerberos requirement
 in the workflow specification.
