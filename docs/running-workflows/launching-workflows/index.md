# Launching workflows from external sources

## About launcher

If your analysis workflows are hosted on external sources such as source code repositories (GitHub, GitLab),
digital repositories (CERN Open Data, Zenodo), or other locations on the web (generic URL),
it is possible to launch your workflows directly from the REANA web interface.
This technique is an alternative way of [executing workflows using a command-line client](/getting-started/first-example/).

For example, to launch a [RooFit demo workflow](https://github.com/reanahub/reana-demo-root6-roofit) from GitHub on REANA instance at CERN, you can click on the badge below:

<p style="text-align:center">
  <img style="width:40%" alt="RooFit plot example" src="https://reana.io/static/img/example-root.png" />
  <br />
  <a href="https://reana.cern.ch/launch?url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit&name=reana-demo-root6-roofit" target="_blank">
    <img src="https://www.reana.io/static/img/badges/launch-on-reana-at-cern.svg" alt="Launch on REANA at CERN badge">
  </a>
</p>

After clicking on the above Launch-on-REANA@CERN badge, you will be redirected to the `reana.cern.ch` instance
and presented with an intermediate launcher page where you can check desired parameters and click on the "Launch" button to execute this workflow.

## Launcher arguments

The launcher functionality is available on `/launch` URL and looks like:

```text
https://reana.cern.ch/launch?url=...&name=...&specification=...&parameters=...
```

Where:

- `url`, pointing to the external source where the analysis is hosted;
- `name` (optional), providing the desired workflow run name (default=workflow);
- `specification` (optional), pointing to the REANA specification file (default=reana.yaml);
- `parameters` (optional), providing encoded list of parameter values for the workflow execution (default=none).

For example, the above badge for RooFit demo workflow is using this URL:

```text
https://reana.cern.ch/launch?url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit&name=reana-demo-root6-roofit
```

The arguments are explained in detail below.
Please note that argument values should be [properly encoded](https://en.wikipedia.org/wiki/Percent-encoding) in order to comply with RFC 2396 URI standard.

### url (required)

`url` is a required argument that points to the external source where your workflow is hosted.
Below you can find supported external sources.

#### Git repositories

You can point to any **publicly available** Git repository to launch a workflow, as long as the URL ends with
`.git` and the scheme is either `http` or `https`. Examples:

- `https://github.com/reanahub/reana-demo-root6-roofit.git`
- `http://example.com:8080/git/repo.git`

If the repository is hosted on GitHub or GitLab, you can further specify
the revision from which the workflow should be launched. Below are examples of supported URL formats:

- `https://github.com/reanahub/reana-demo-root6-roofit`
- `https://github.com/reanahub/reana-demo-root6-roofit/tree/my-branch` (to launch a particular branch)
- `https://github.com/reanahub/reana-demo-root6-roofit/tree/v1.0` (to launch a particular tag)
- `https://github.com/reanahub/reana-demo-root6-roofit/tree/3441d3b2d417c7f39f091a1d7f0df38bdaca82e8` (to launch a particular commit hash)

#### ZIP tarballs

Another option is to point to a ZIP tarball on any generic hosting service, for example `https://zenodo.org/record/5752285/files/circular-health-data-processing-master.zip`.
In order for REANA to correctly launch the workflow, the archive should contain the REANA specification file
and all the input files and directories needed by the workflow.

#### REANA specification files

You can also point directly to a remote REANA specification file, such as `https://example.org/reana.yaml`.
In this case, the workflow should fetch the required input files on its own as part of the workflow execution.

### name (optional)

The launch page accepts an optional `name` argument that will determine the desired name of the launched workflow.
If the argument is missing, REANA will generate a name based on the URL of the external source, repository or branch name.
Example usage:

```text
https://reana.cern.ch/launch?name=my-analysis&url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit
```

### specification (optional)

If your workflow uses a different REANA specification file than the default `reana.yaml`,
you can specify the path to the desired specification file using the `specification` optional argument:

```text
https://reana.cern.ch/launch?specification=reana-snakemake.yaml&url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit
```

### parameters (optional)

You can optionally send extra parameters for the workflow execution that would override the ones specified in your REANA specification file.
For example, the [RooFit demo example](https://github.com/reanahub/reana-demo-root6-roofit) uses `events` parameter to determine how many events to generate.
If you would like to override the default value of 20000 to, say, 30000, you can pass in a JSON format:

```text
parameters={"events": "30000"}
```

Note that the value should be properly encoded, which gives:

```text
...?parameters=%7B%22events%22%3A%20%2230000%22%7D
```

Final URL looks like this:

```text
https://reana.cern.ch/launch?parameters=%7B%22events%22%3A%20%2230000%22%7D&url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit
```

## Launcher badges

You may want to generate a custom "Launch-on-REANA" badge and include it in your source code repository so the analysis would be runnable with a single click.

The standard set of badges look as follows:

![Launch on REANA](https://www.reana.io/static/img/badges/launch-on-reana.svg)

![Launch on REANA at CERN](https://www.reana.io/static/img/badges/launch-on-reana-at-cern.svg)

![Launch with CWL on REANA at CERN](https://www.reana.io/static/img/badges/launch-with-cwl-on-reana-at-cern.svg)

![Launch with Yadage on REANA at CERN](https://www.reana.io/static/img/badges/launch-with-yadage-on-reana-at-cern.svg)

![Launch with Serial on REANA at CERN](https://www.reana.io/static/img/badges/launch-with-serial-on-reana-at-cern.svg)

![Launch with Snakemake REANA at CERN](https://www.reana.io/static/img/badges/launch-with-snakemake-on-reana-at-cern.svg)

If you would like to generate your own custom badge, you can use external services such as [shields.io](https://shields.io) or [badgen.net](https://badgen.net).

### Markdown

You can include one of the above badges into your Markdown documentation pages using the following syntax:

```markdown
[![Launch on REANA badge](https://www.reana.io/static/img/badges/launch-on-reana.svg)](https://reana.cern.ch/launch?url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit)
```

This example points to the RooFit analysis demo. You should replace the `url` to point to your own analysis sources.

### HTML

You can include one of the above badges into your HTML documentation pages using the following syntax:

```html
<a href="https://reana.cern.ch/launch?url=https%3A%2F%2Fgithub.com%2Freanahub%2Freana-demo-root6-roofit"><img src="https://www.reana.io/static/img/badges/launch-on-reana.svg" alt="Launch on REANA badge"></a>
```
