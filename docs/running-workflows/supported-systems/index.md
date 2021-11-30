# Supported systems

| Engine                 | Parametrised? | Parallel execution? | Partial execution? |
| ---------------------- | ------------- | ------------------- | ------------------ |
| [CWL](cwl)             | yes           | yes                 | no (1)             |
| [Serial](serial)       | yes           | no                  | yes                |
| [Yadage](yadage)       | yes           | yes                 | no (1)             |
| [Snakemake](snakemake) | yes           | yes                 | no (1)             |

(1) The vanilla workflow system may support the feature, but not when run
via REANA environment.
