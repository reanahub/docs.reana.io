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
you must specify `htcondorcern` as the step's execution backend in the
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

## Choosing container execution mode

REANA supports two container execution modes for HTCondor steps. The mode is
selected by the image given in `environment` and by the `unpacked_img` hint.

### Docker images

Docker execution is the default mode. Specify a regular Docker or OCI image
reference in `environment`, as in the example above, and omit `unpacked_img`
(or set it to `false`). REANA passes the image to the CERN HTCondor Docker
integration, which obtains it from the container registry and starts the job.

This mode is appropriate for images stored in a container registry. The image
must be accessible from the HTCondor execution infrastructure.

### Apptainer with CVMFS unpacked images

The Apptainer mode executes an image that is already unpacked in a directory
available through CVMFS on the HTCondor execution machine. At CERN, many such
images are published below `/cvmfs/unpacked.cern.ch/`; see the
[CernVM-FS container image documentation](https://cvmfs.readthedocs.io/en/latest/cpt-containers/#using-unpackedcernch).
Set `environment` to the full CVMFS path and set `unpacked_img` to `true`:

```yaml hl_lines="5 7"

   # Serial example
   ...
   steps:
      - name: python_version
        environment: '/cvmfs/unpacked.cern.ch/registry.hub.docker.com/library/python:3.10'
        compute_backend: htcondorcern
        unpacked_img: true
        commands:
            - python --version
```

In this mode, REANA launches the command through the Apptainer wrapper on the
execution machine. The image path is not downloaded or transferred with the
job, so it must already exist and be readable there.

See [Apptainer containers](../../containers/apptainer/index.md) for why the
hint is required, the support offered by each compute backend, and a Snakemake
example.

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

## Requesting CPU, memory, and disk resources

As of REANA 0.95 release series, you can request specific CPU, memory,
and disk resources for individual HTCondor steps.

HTCondor matches jobs against execution machines based on the resources
they request. By default, REANA does not set any explicit resource
request and the job inherits the pool's defaults. If your step needs
more CPU cores, memory, or scratch disk than the default slot offers,
you can ask for them explicitly via three optional hints.

### Number of CPU cores

To request a specific number of CPU cores for the step, set
`htcondor_request_cpus` to a positive integer (passed as a string).
This is translated to the `RequestCpus` HTCondor submit attribute.

```yaml hl_lines="7"

   # Serial example
   ...
   steps:
      - name: reana_demo_helloworld_htcondorcern
        environment: 'python:2.7-slim'
        compute_backend: htcondorcern
        htcondor_request_cpus: '4'
        commands:
            - python helloworld.py
```

### Memory

To request a specific amount of memory for the step, set
`htcondor_request_memory` to a positive integer with an optional unit suffix.
The accepted suffixes are `K`, `KB`, `M`, `MB`, `G`, `GB`, `T`, `TB`
(case-insensitive, binary multipliers). If you omit the suffix the value is
interpreted as megabytes, matching HTCondor's native `RequestMemory`
convention. Kubernetes-style `Mi`/`Gi` suffixes are not accepted here; this is
an HTCondor hint, not a Kubernetes one.

```yaml hl_lines="7"

   # Serial example
   ...
   steps:
      - name: reana_demo_helloworld_htcondorcern
        environment: 'python:2.7-slim'
        compute_backend: htcondorcern
        htcondor_request_memory: '4 GB'
        commands:
            - python helloworld.py
```

### Disk

To request a specific amount of scratch disk for the step, set
`htcondor_request_disk` to a positive integer with an optional unit suffix. The
accepted suffixes are the same as for memory. If you omit the suffix the value
is interpreted as kilobytes, matching HTCondor's native `RequestDisk`
convention.

```yaml hl_lines="7"

   # Serial example
   ...
   steps:
      - name: reana_demo_helloworld_htcondorcern
        environment: 'python:2.7-slim'
        compute_backend: htcondorcern
        htcondor_request_disk: '10 GB'
        commands:
            - python helloworld.py
```

## Selecting the execution machine

As of REANA 0.95 release series, you can also constrain which execution
machines HTCondor is allowed to pick for a step.

For finer-grained control over which execution machines HTCondor may schedule
the step on, you can pass a raw ClassAd `Requirements` expression via
`htcondor_requirements`. Any ClassAd expression accepted by HTCondor is
allowed.

The expression you supply becomes the job's *complete* `Requirements`
expression; HTCondor's usual submit-side defaults are not appended to it. This
keeps submission architecture-neutral, since those defaults would otherwise
constrain the step to the architecture and the operating system of the machine
that submitted it. If your step needs a constraint, state it explicitly.

Resource requests such as `htcondor_request_memory` are not affected, since
they are passed as separate submit attributes and are still taken into account
when matching execution machines. Site policies configured on the HTCondor
schedd and on the execution machines continue to apply as usual.

A common use case is restricting the step to a specific CPU architecture, for
example to run only on ARM (`aarch64`) machines:

```yaml hl_lines="7"

   # Serial example
   ...
   steps:
      - name: reana_demo_helloworld_htcondorcern
        environment: 'python:2.7-slim'
        compute_backend: htcondorcern
        htcondor_requirements: '(TARGET.Arch =?= "aarch64")'
        commands:
            - python helloworld.py
```

Note that overly restrictive requirements may leave the job idle in the queue
indefinitely if no matching machine is available, so prefer loosening the
constraint (or removing it altogether) when you no longer need it.
