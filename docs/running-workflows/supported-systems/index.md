# Supported workflow engines

REANA supports several workflow engines for defining and orchestrating computational workflows:

| Engine                 | Parametrised? | Parallel execution? | Partial execution? |
| ---------------------- | ------------- | ------------------- | ------------------ |
| [CWL](cwl)             | yes           | yes                 | no (1)             |
| [Serial](serial)       | yes           | no                  | yes                |
| [Yadage](yadage)       | yes           | yes                 | no (1)             |
| [Snakemake](snakemake) | yes           | yes                 | no (1)             |

(1) The vanilla workflow system may support the feature, but not when run
via REANA environment.

## Using Dask in workflows

Dask complements these workflow engines by providing a dedicated cluster for computations performed by your analysis code. You still use Serial, CWL, Yadage, or Snakemake to orchestrate the workflow, while REANA provisions the Dask cluster requested in your workflow resource hints. Learn how to [use Dask in your workflow](../dask).
