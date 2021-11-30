# Kerberos

If your workflow needs to access external services from within the job such as
EOS you could use Kerberos authentication.

## Generating keytab file

First, generate a Kerberos keytab file for passwordless authentication.

```console
# login to lxplus and generate keytab file
$ ssh johndoe@lxplus.cern.ch
$ ktutil
ktutil:  add_entry -password -p johndoe@CERN.CH -k 1 -e aes256-cts-hmac-sha1-96
Password for johndoe@CERN.CH:
ktutil:  add_entry -password -p johndoe@CERN.CH -k 1 -e arcfour-hmac
Password for johndoe@CERN.CH:
ktutil:  write_kt .keytab
ktutil:  exit

# Let's test generated keytab file by trying to generate Kerberos ticket
$ scp johndoe@lxplus.cern.ch:~/.keytab .
$ kinit -kt ~/.keytab johndoe@CERN.CH
$ klist
Ticket cache: FILE:/tmp/krb5cc_1000
Default principal: johndoe@CERN.CH

Valid starting       Expires              Service principal
04/29/2019 11:24:12  04/30/2019 12:23:52  krbtgt/CERN.CH@CERN.CH
  renew until 05/04/2019 11:23:52
04/29/2019 11:24:49  04/30/2019 12:23:52  host/tweetybird04.cern.ch@CERN.CH
  renew until 05/04/2019 11:23:52
04/29/2019 11:25:00  04/30/2019 12:23:52  host/bigbird14.cern.ch@CERN.CH
  renew until 05/04/2019 11:23:52
```

## Uploading secrets

Once you have a working keytab file, you need to upload your CERN username
and keytab secrets to REANA:

```console
$ reana-client secrets-add --env CERN_USER=johndoe \
                           --env CERN_KEYTAB=.keytab \
                           --file ~/.keytab
```

## Setting Kerberos requirement

Set `kerberos: true` for the steps in need in the workflow specification.
Please note that step's docker image (e.g `environment: 'cern/slc6-base'`)
should have Kerberos client installed and you have to for the Kerberos
authentication to work.

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
    kerberos: true
  container: "docker://python:2.7-slim"
```

> Please note that Kerberos token is automatically provided for HTCondor and
 Slurm compute backend jobs and there is no need to specify kerberos requirement
 in the workflow specification.
