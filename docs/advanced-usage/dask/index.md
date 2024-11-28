# Dask

REANA supports the integration of Dask clusters to provide scalable, distributed computing capabilities for workflows. This documentation explains how to set up and configure a Dask cluster using REANA which is dedicated for your workflow, query cluster settings, and utilize Dask's features such as the dashboard for monitoring your workflows.

## Setting up Dask cluster

To configure your Dask cluster, you can set 3 different variables in `reana.yaml`

1. **image** (mandatory)  
   Specifies the Docker image to be used by the Dask workers, scheduler, and the job pod that executes your analysis. Ensure the image includes all dependencies required for your workflow.
   
2. **number_of_workers** (optional)   
   Defines the number of Dask workers for your cluster. If not specified, a default value configured by your REANA cluster administrator will be used. If you request more workers than the allowed maximum, the following error occurs:
   ```console
   $ reana-client run -w my-dask-workflow
   ...
   ==> ERROR: Cannot create workflow :
   The number of requested Dask workers (N) exceeds the maximum limit (M).
   ```
   In such cases, reduce the number of workers and try again.

3. **single_worker_memory** (optional)  
   Sets the amount of memory allocated to each Dask worker. If not specified, a default value configured by your REANA cluster administrator will be used. Requests exceeding the maximum allowed memory per worker will also result in the following error:
   ```console
   $ reana-client run -w my-dask-workflow
   ...
   ==> ERROR: Cannot create workflow :
   The "single_worker_memory" provided in the dask resources exceeds the limit (8Gi).
   ```

An example configuration:

```yaml
...
resources:
   dask:
      image: docker.io/coffeateam/coffea-dask-cc7:0.7.22-py3.10-g7f049
      number_of_workers: 5
      single_worker_memory: 8Gi
...
```

## Querying Dask Settings and Limits

REANA administrators set some settings and limits about the Dask clusters such as maximum memory limit and whether autoscaler is enabled or not. You can query them with `reana-client info` command.

```console
$ reana-client info
...
Dask autoscaler enabled in the cluster: True
The number of Dask workers created by default: 2
The amount of memory used by default by a single Dask worker: 2Gi
The maximum memory limit for Dask clusters created by users: 16Gi
The maximum number of workers that users can ask for the single Dask cluster: 20
The maximum amount of memory that users can ask for the single Dask worker: 8Gi
Dask workflows allowed in the cluster: True
...
```

## Usage

Once you configure your dask cluster via `reana.yaml`, REANA runs your workflow within an environment and provides the scheduler's uri via environment variable called `DASK_SCHEDULER_URI`. You can use the environment variable as follows:

```python
...
import os
from dask.distributed import Client

DASK_SCHEDULER_URI = os.getenv("DASK_SCHEDULER_URI")
client = Client(DASK_SCHEDULER_URI)
...

```

You can also refer to the demo [here](https://github.com/reanahub/reana-demo-dask-coffea) for a full example which uses Dask with analysis code and `reana.yaml`.

## Dask Dashboard

You can inspect your analysis and Dask cluster via Dask dashbard by clicking the following icon under your workflow. 

![Dask-dashboard-icon](https://github.com/user-attachments/assets/516951d4-3198-4070-a8a2-bc6a8f651cf1)

### An example Dask Dashboard
![Dask-dashboard](https://github.com/user-attachments/assets/90b5c012-e829-4561-95c1-48cc710a9f90)
