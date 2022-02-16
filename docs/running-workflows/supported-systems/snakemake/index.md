# Snakemake

Snakemake is a popular workflow management system originated in bioinformatics in 2012, for
reproducible and scalable data analyses. It describes workflows via a readable, Python-based
language, and allows them to be scaled without the need for modifications.

Snakemake workflows can describe the software required to run them, which is automatically
deployed in any execution environment.

The integration of Snakemake in the REANA platform allows Snakemake users to profit from the
other regular REANA features in their workflows. For example, it is possible to execute hybrid
workflows where some parts of calculations are executed on HTCondor high-throughput compute
backend, other parts on Slurm high-performance compute backend, and yet other parts on the
default Kubernetes compute backend. For more information about this topic please refer to the
blog post mentioned below.

For additional information, please see:

- Snakemake documentation: [https://snakemake.readthedocs.io](https://snakemake.readthedocs.io)
- REANA blog post: [https://blog.reana.io/posts/2021/support-for-running-snakemake-workflows](https://blog.reana.io/posts/2021/support-for-running-snakemake-workflows/)

## Supported versions

| REANA version         | Snakemake |
| ----------------------|-----------|
| 0.8 release series    | 6.8.0     |
