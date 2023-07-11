# Configuring compute backends

The REANA platform is able to dispatch user jobs to several supported compute
backends including HTCondor, Kubernetes and Slurm. The following documentation
explains how to configure them from the administrator point of view.

!!! note

    This page is addressed to computer engineers deploying the REANA platform
    on their clusters. If you are a researcher looking for information on how
    to configure your workflows so that your jobs would be sent to a particular
    supported compute backend, please see the corresponding [user-oriented
    compute backend documentation](../../../advanced-usage/compute-backends)
    pages instead.

## HTCondor

The HTCondor compute backend is useful for high-throughput user computing
needs. Currently REANA supports the HTCondor batch system at CERN
(`htcondorcern`).

If you wish to offer the HTCondor compute backend to users in your
installation, please include the `htcondorcern` value in the Helm list
[`compute_backends`](https://github.com/reanahub/reana/tree/master/helm/reana)
and customise the
[`components.reana_job_controller.image`](https://github.com/reanahub/reana/tree/master/helm/reana)
value to use an image compiled with the HTCondor CERN backend support, such as
`reanahub/reana-job-controller-htcondorcern-slurmcern:0.9.0`.

Currently it is not possible to further customise the HTCondor integration
through additional Helm values or environment variables. Please get in touch
should you need to customise the HTCondor integration further in your REANA
deployment.

Here is a customisation snippet example:

```yaml
compute_backends:
  - kubernetes
  - htcondorcern
components:
  reana_job_controller:
    image: docker.io/reanahub/reana-job-controller-htcondorcern-slurmcern:0.9.0
```

## Kubernetes

Kubernetes is the default compute backend used by REANA for user jobs. It does
not require any particular configuration on the cluster administration side.

If you would like to further customise the Kubernetes compute backend, you can
set various Helm values during deployment that will affect the scheduling of
user job pods:

- If you are using
  [`node_label_runtimejobs`](https://github.com/reanahub/reana/tree/master/helm/reana)
  Helm value, the jobs will be scheduled only to the cluster nodes that are
  labelled with the corresponding label value, such as
  `reana.io/system=runtimejobs`. The dynamic labelling of nodes allows to
  increase/decrease the cluster job capacity based on increasing/decreasing
  user workload demands. The node labelling system is described in a dedicated
  document [Deploying at scale](../../deployment/deploying-at-scale/).

- The default memory limit for user job containers is governed by the Helm
  value
  [`kubernetes_jobs_memory_limit`](https://github.com/reanahub/reana/tree/master/helm/reana).
  If a user job exceeds this limit, the user job will be terminated and an
  error reported back to the user. By default the limit is around 4 GiB. Please
  set this variable based on the cluster node flavours you have in your system
  and the typical user workflow memory needs.

- The maximum memory limit a user can request is governed by the Helm value
  [`kubernetes_jobs_max_user_memory_limit`](https://github.com/reanahub/reana/tree/master/helm/reana).
  For example, you can allow users to request up to 10 GiB of memory even
  though the default is 4 GiB. If a user would request more than this value,
  the job would not be accepted.

- The default runtime limit for user job containers is governed by the Helm
  value
  [`kubernetes_jobs_timeout_limit`](https://github.com/reanahub/reana/tree/master/helm/reana).
  If a user job exceeds this limit, the user job will be terminated and an
  error reported back to the user. By default the runtime limit is about 7
  days. Please set this variable based on the typical user workflow runtime
  needs in your installation.

- The maximum runtime limit a user can request is governed by the Helm value
  [`kubernetes_jobs_max_user_timeout_limit`](https://github.com/reanahub/reana/tree/master/helm/reana).
  For example, you can allow users to request a runtime of up to 14 days even
  though the default is 7 days. If a user would request more than this value,
  the job would not be accepted.

Here is a customisation snippet example:

```yaml
compute_backends:
  - kubernetes
kubernetes_jobs_memory_limit: 2Gi
kubernetes_jobs_max_user_memory_limit: 10Gi
```

## Slurm

The Slurm compute backend is useful for high-performance user computing needs.
Currently REANA supports the Slurm batch system at CERN (`slurmcern`).

If you wish to include the Slurm compute backend in your installation, please
include the `slurmcern` value in the Helm list
[`compute_backends`](https://github.com/reanahub/reana/tree/master/helm/reana)
and customise the
[`components.reana_job_controller.image`](https://github.com/reanahub/reana/tree/master/helm/reana)
value to use an image compiled with the Slurm CERN backend support, such as
`reanahub/reana-job-controller-htcondorcern-slurmcern:0.9.0`.

Currently it is not possible to further customise the Slurm integration through
additional Helm values or environment variables. Please get in touch should you
need to customise the Slurm integration further in your REANA deployment.

Here is a customisation snippet example:

```yaml
compute_backends:
  - kubernetes
  - slurmcern
components:
  reana_job_controller:
    image: docker.io/reanahub/reana-job-controller-htcondorcern-slurmcern:0.9.0
```
