# HTCondor

HTCondor is a specialized workload management system for compute-intensive jobs
and it is supported by REANA alongside primary job execution backend Kubernetes
and Slurm.

## Authentication

In order to use CERN HTcondor cluster you need to be authenticated using
Kerberos.

### Keytab generation

First, generate a Kerberos keytab file for passwordless authentication.

```console
# login to lxplus and generate keybab file
$ ssh johndoe@lxplus.cern.ch
$ ktutil
ktutil:  add_entry -password -p johndoe@CERN.CH -k 1 -e aes256-cts-hmac-sha1-96
Password for johndoe@CERN.CH:
ktutil:  add_entry -password -p johndoe@CERN.CH -k 1 -e arcfour-hmac
Password for johndoe@CERN.CH:
ktutil:  write_kt .keytab
ktutil:  exit

# Let''s test generated keytab file by trying to generate Kerberos ticket
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

### Uploading secrets

Once you have working keytab file, you need to upload your CERN username
and keytab secrets to REANA:

```console
$ reana-client secrets-add --env CERN_USER=johndoe \
                           --env CERN_KEYTAB=.keytab \
                           --file ~/.keytab
```

## Specifying compute backend

In order to execute the certain steps of a workflow on the CERN HTCondor cluster
you must specify ``htcondorcern`` as the step's execution backend in the
workflow specification.

```yaml hl_lines="6"

   # Serial example
   ...
   steps:
      - name: reana_demo_helloworld_htcondorcern
        environment: 'python:2.7-slim'
        compute_backend: htcondorcern
        commands:
            - python "${helloworld}"
```

Examples for CWL and Yadage can be found in
[REANA example - "hello world"](https://github.com/reanahub/reana-demo-helloworld)
