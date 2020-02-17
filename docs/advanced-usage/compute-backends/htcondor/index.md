# HTCondor

HTCondor is a specialized workload management system for compute-intensive jobs
and it is supported by REANA alongside primary job execution backend Kubernetes
and Slurm.

## Authentication

In order to use CERN HTCondor cluster you need to be authenticated using
Kerberos. [Generate keytab file](../../access-control/kerberos/index.md#generating-keytab-file)
and [upload it and your CERN username as secrets to REANA](../../access-control/kerberos/index.md#uploading-secrets).

## Specifying compute backend

In order to execute certain steps of a workflow on the CERN HTCondor cluster
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
            - python helloworld.py
```

Examples for CWL and Yadage can be found in
[REANA example - "hello world"](https://github.com/reanahub/reana-demo-helloworld)
