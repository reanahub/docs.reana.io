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

## Custom memory limit

When jobs exceed the cluster memory limits, you will get out of memory (OOM) error and job gets [`OOMKilled`](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits). To avoid OOM error, you can increase the **memory** limits per workflow step to make an efficient use of the available resources. Note that you can also decrease the memory limit to increment the chances of jobs being scheduled earlier if the cluster is busy.

To set the memory limit of a job you can specify `kubernetes_memory_limit` in the specification of **each workflow step**.

Read more about the expected memory values on [Kubernetes official documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory)

You can configure the `steps` in the respective `yaml` specifications for Serial, Yadage, and CWL workflow engines.

### Serial workflow

You can set `kubernetes_memory_limit` in every `step` of workflow specification.

```yaml hl_lines="6"
   ...
   steps:
      - name: reana_demo_helloworld_memory_limit
        environment: 'python:2.7-slim'
        compute_backend: kubernetes
        kubernetes_memory_limit: '8Gi'
        commands:
            - python helloworld.py
```

### Yadage workflow

You can set `kubernetes_memory_limit` in every `step` under `environment.resources`.

```yaml hl_lines="19"
   ...
   stages:
   - name: reana_demo_helloworld_memory_limit
      dependencies: [init]
      scheduler:
        scheduler_type: 'singlestep-stage'
        parameters:
          helloworld: {step: init, output: helloworld}
        step:
          process:
            process_type: 'string-interpolated-cmd'
            cmd: 'python "{helloworld}"'
          environment:
            environment_type: 'docker-encapsulated'
            image: 'python'
            imagetag: '2.7-slim'
            resources:
              - compute_backend: kubernetes
              - kubernetes_memory_limit: '8Gi'
```

### CWL workflow

You can set `kubernetes_memory_limit` in every `step` under `hints.reana`.

```yaml hl_lines="7"
   ...
   steps:
    first:
      hints:
        reana:
          compute_backend: kubernetes
          kubernetes_memory_limit: '8Gi'
      run: helloworld_memory_limit.tool
      in:
        helloworld: helloworld_memory_limit
      out: [result]
```
