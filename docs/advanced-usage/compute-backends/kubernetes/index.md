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
      environment: 'docker.io/library/python:2.7-slim'
      compute_backend: kubernetes
      commands:
        - python "${helloworld}"
```

## Custom CPU configuration

Starting from REANA 0.95.0 release series, when jobs need specific CPU guarantees or limits, you can configure both CPU requests and limits. CPU requests specify the minimum amount of CPU resources that must be available for a container to start, while CPU limits specify the maximum amount of CPU a container can use. When containers try to use more CPU than their limit, they will be throttled.

You can specify both `kubernetes_cpu_request` and `kubernetes_cpu_limit` in the specification of **each workflow step**. Note that lowering the CPU request can help jobs get scheduled earlier if the cluster is busy, since Kubernetes scheduling is driven by requests. The CPU limit, on the other hand, mainly constrains runtime usage once the pod is running.

Read more about the expected CPU values in the [Kubernetes official documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-cpu).

You can configure CPU settings in the respective specifications for Serial, Yadage, CWL and Snakemake workflow engines.

For **Serial**, you can set CPU configuration in each `step` of a workflow specification:

```yaml hl_lines="6 7"
  ...
  steps:
    - name: reana_demo_helloworld_cpu
      environment: 'docker.io/library/python:2.7-slim'
      compute_backend: kubernetes
      kubernetes_cpu_request: '1'    # Minimum CPU cores required
      kubernetes_cpu_limit: '2'      # Maximum CPU cores allowed
      commands:
        - python helloworld.py
```

For **Yadage**, you can set CPU configuration in every `step` under `environment.resources`:

```yaml hl_lines="19 20"
  ...
  stages:
    - name: reana_demo_helloworld_cpu
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
            image: 'docker.io/library/python'
            imagetag: '2.7-slim'
            resources:
              - compute_backend: kubernetes
              - kubernetes_cpu_request: '1'
              - kubernetes_cpu_limit: '2'
```

For **CWL**, you can set CPU configuration in every `step` under `hints.reana`:

```yaml hl_lines="7 8"
  ...
  steps:
    first:
      hints:
        reana:
          compute_backend: kubernetes
          kubernetes_cpu_request: '1'
          kubernetes_cpu_limit: '2'
      run: helloworld_cpu.tool
      in:
        helloworld: helloworld_cpu
      out: [result]
```

For **Snakemake**, you can set CPU configuration in every `rule` under `resources`:

```yaml hl_lines="10 11"
  ...
  rule helloworld:
    input:
        helloworld=config["helloworld"],
        inputfile=config["inputfile"],
    output:
        "results/greetings.txt"
    resources:
        compute_backend="kubernetes",
        kubernetes_cpu_request="1",
        kubernetes_cpu_limit="2"
    container:
        "docker://docker.io/library/python:2.7-slim"
```

## Custom memory configuration

Starting from REANA 0.95.0 release series, when jobs need specific memory guarantees or exceed the cluster memory limits, you can configure both memory requests and limits. Please note that memory limits were already supported since REANA 0.7.4. Memory requests specify the minimum amount of memory that must be available for a container to start, while memory limits specify the maximum amount of memory a container can use. When containers exceed their memory limits, they will be terminated with an [`OOMKilled`](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits) status.

You can specify both `kubernetes_memory_request` and `kubernetes_memory_limit` in the specification of **each workflow step**. Note that lowering the memory request can help jobs get scheduled earlier if the cluster is busy, since Kubernetes scheduling is driven by requests. The memory limit, on the other hand, mainly constrains runtime usage once the pod is running.

Read more about the expected memory values in the [Kubernetes official documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory).

You can configure memory settings in the respective specifications for Serial, Yadage, CWL and Snakemake workflow engines.

For **Serial**, you can set memory configuration in each `step` of a workflow specification:

```yaml hl_lines="6 7"
  ...
  steps:
    - name: reana_demo_helloworld_memory
      environment: 'docker.io/library/python:2.7-slim'
      compute_backend: kubernetes
      kubernetes_memory_request: '4Gi'  # Minimum memory required
      kubernetes_memory_limit: '8Gi'    # Maximum memory allowed
      commands:
        - python helloworld.py
```

For **Yadage**, you can set memory configuration in every `step` under `environment.resources`:

```yaml hl_lines="19 20"
  ...
  stages:
    - name: reana_demo_helloworld_memory
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
            image: 'docker.io/library/python'
            imagetag: '2.7-slim'
            resources:
              - compute_backend: kubernetes
              - kubernetes_memory_request: '4Gi'
              - kubernetes_memory_limit: '8Gi'
```

For **CWL**, you can set memory configuration in every `step` under `hints.reana`:

```yaml hl_lines="7 8"
  ...
  steps:
    first:
      hints:
        reana:
          compute_backend: kubernetes
          kubernetes_memory_request: '4Gi'
          kubernetes_memory_limit: '8Gi'
      run: helloworld_memory.tool
      in:
        helloworld: helloworld_memory
      out: [result]
```

For **Snakemake**, you can set memory configuration in every `rule` under `resources`:

```yaml hl_lines="10 11"
  ...
  rule helloworld:
    input:
        helloworld=config["helloworld"],
        inputfile=config["inputfile"],
    output:
        "results/greetings.txt"
    resources:
        compute_backend="kubernetes",
        kubernetes_memory_request="4Gi",
        kubernetes_memory_limit="8Gi"
    container:
        "docker://docker.io/library/python:2.7-slim"
```

## Custom job timeouts

When a job exceeds the specified time limit, it will be terminated by Kubernetes and marked as failed.

To set the job timeout, you can declare `kubernetes_job_timeout` in the specification of **each workflow step**.
Time is measured in **seconds**.

Read more about the job run time deadline limits in the [Kubernetes official documentation](https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup).

You can configure the `steps` in the respective specifications for Serial, Yadage, CWL and Snakemake workflow engines.

For **Serial**, you can set `kubernetes_job_timeout` in each `step` of a workflow specification:

```yaml hl_lines="6"
  ...
  steps:
    - name: reana_demo_helloworld_job_timeout
      environment: 'docker.io/library/python:2.7-slim'
      compute_backend: kubernetes
      kubernetes_job_timeout: 60
      commands:
        - python helloworld.py
```

For **Yadage**, you can set `kubernetes_job_timeout` in every `step` under `environment.resources`:

```yaml hl_lines="19"
  ...
  stages:
    - name: reana_demo_helloworld_job_timeout
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
            image: 'docker.io/library/python'
            imagetag: '2.7-slim'
            resources:
              - compute_backend: kubernetes
              - kubernetes_job_timeout: 60
```

For **CWL**, you can set `kubernetes_job_timeout` in every `step` under `hints.reana`:

```yaml hl_lines="7"
  ...
  steps:
    first:
      hints:
        reana:
          compute_backend: kubernetes
          kubernetes_job_timeout: 60
      run: helloworld_job_timeout.tool
      in:
        helloworld: helloworld_job_timeout
      out: [result]
```

For **Snakemake**, you can set `kubernetes_job_timeout` in every `rule` under `resources`:

```yaml hl_lines="12"
  ...
  rule helloworld:
    input:
        helloworld=config["helloworld"],
        inputfile=config["inputfile"],
    params:
        sleeptime=config["sleeptime"]
    output:
        "results/greetings.txt"
    resources:
        compute_backend="kubernetes",
        kubernetes_job_timeout=60
    container:
        "docker://docker.io/library/python:2.7-slim"
  ...
```
