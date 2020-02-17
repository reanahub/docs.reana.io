# Slurm

Slurm is a specialized workload management system for high performance
computing jobs and it is supported by REANA alongside primary job execution
backend Kubernetes and HTCondor.

## Authentication

In order to use CERN Slurm cluster you need to be authenticated using
Kerberos. [Generate keytab file](../../access-control/kerberos/index.md#generating-keytab-file)
and [upload it and your CERN username as secrets to REANA](../../access-control/kerberos/index.md#uploading-secrets).

## Specifying compute backend

In order to execute certain steps of a workflow on the CERN Slurm cluster
you must specify ``slurmcern`` as the step's execution backend in the
workflow specification.

```yaml hl_lines="6"

   # Serial example
   ...
   steps:
      - name: reana_demo_helloworld_htcondorcern
        environment: 'python:2.7-slim'
        compute_backend: slurmcern
        commands:
            - python "${helloworld}"
```

Examples for CWL and Yadage can be found in
[REANA example - "hello world"](https://github.com/reanahub/reana-demo-helloworld)

> Please note that CERN Slurm cluster access is [not granted by
default](https://batchdocs.web.cern.ch/linuxhpc/access.html)
