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

## Aid job scheduling

HTCondor uses priorities to allocate machines to run jobs. With REANA there are two values you can specify to help schedule a job appropriately.

To set the maximum runtime of a job you must specify `htcondor_max_runtime`.
This can either be set directly in seconds or by assigning it a "flavour". Note that jobs exceeding the maximum runtime
will be terminated. The possible job flavours are:

```yaml
espresso     = 20 minutes
microcentury = 1 hour
longlunch    = 2 hours
workday      = 8 hours
tomorrow     = 1 day
testmatch    = 3 days
nextweek     = 1 week
```

```yaml hl_lines="7"

   # Serial example
   ...
   steps:
      - name: reana_demo_helloworld_htcondorcern
        environment: 'python:2.7-slim'
        compute_backend: htcondorcern
        htcondor_max_runtime: '3600'
        commands:
            - python helloworld.py
```

```yaml hl_lines="7"

   # Serial example
   ...
   steps:
      - name: reana_demo_helloworld_htcondorcern
        environment: 'python:2.7-slim'
        compute_backend: htcondorcern
        htcondor_max_runtime: 'espresso'
        commands:
            - python helloworld.py
```

If you are part of a HTCondor accounting group and you would like to set accounting to a per-group basis, you must specify `htcondor_accounting_group`.

```yaml hl_lines="7"

   # Serial example
   ...
   steps:
      - name: reana_demo_helloworld_htcondorcern
        environment: 'python:2.7-slim'
        compute_backend: htcondorcern
        htcondor_accounting_group: 'group_physics'
        commands:
            - python helloworld.py
```
