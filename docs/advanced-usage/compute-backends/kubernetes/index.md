# Kubernetes

REANA supports Kubernetes as a primary and default job execution backend alongside
HTCondor and Slurm.

If `step` does not contain `compute_backend` specification, it will be executed
on the default backend.


```yaml hl_lines="6"

   # Serial example
   ...
   steps:
      - name: reana_demo_helloworld_htcondorcern
        environment: 'python:2.7-slim'
        compute_backend: kubernetes
        commands:
            - python "${helloworld}"
```
