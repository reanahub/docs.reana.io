# reana.yaml

## About `reana.yaml`

The REANA reproducible analysis platform requires to have `reana.yaml` file
present in your analysis source code.  This is a so called REANA specification
file. Its purpose is to answer the Four Questions:

1. What is your input data?
2. Which code analyses it?
3. What is your computing environment?
4. Which computational steps do you take to arrive at results?

This reference guide describes how the Four Questions are transcribed into
`reana.yaml` REANA specification file.

!!! note

    The REANA specification file uses a human-readable data-serialisation language
    called [YAML](https://yaml.org/). YAML uses Python-like whitespace indentation
    and supports basic data types such as strings, lists, dictionaries. More
    information can be found in the [official YAML
    documentation](https://yaml.org/spec/1.2/spec.html).

## Understanding `reana.yaml`

The `reana.yaml` file describes the analysis as a computational workflow with
its inputs, workflow specification, and its outputs.  The overall structure of
`reana.yaml` looks as follows:

| Property | Type         | Mandatory?  | Description                                                                                                              |
| -------- | ----         | ----------  | -----------                                                                                                              |
| version  | *string*     | *optional*  | Specifies REANA version to which the analysis was written for. For example, "0.6.0".                                     |
| inputs   | *dictionary* | *optional*  | Specifies all the high-level inputs to the workflow. Can be composed of "files", "directories", "parameters", "options". |
| workflow | *dictionary* | *mandatory* | Defines computational workflow, using CWL, Serial or Yadage specifications.                                              |
| outputs  | *dictionary* | *optional*  | Specifies all the high-level outputs of the workflow.  Can be composed of "files" and "directories".                                       |

Each property will be described in detail in the following sections.

### reana.yaml version

The **version** property of `reana.yaml` specifies REANA platform version to which the analysis was written for.  It can be useful for long-term preservation in case the REANA specification file structure may change in the future. The property is optional.

The **version** property value is a string:

| Property | Type     | Mandatory? | Description                                                                          |
| -------- | ----     | ---------- | -----------                                                                          |
| version  | *string* | *optional* | Specifies REANA version to which the analysis was written for. For example, "0.6.0". |

The **version** property example:

```yaml
version: 0.6.0
```

### reana.yaml inputs

The **inputs** property of `reana.yaml` specifies all the workflow high-level inputs, be they files, directories, or parameters with values. The property serves to document all the initial inputs to the workflow.  The `reana-client upload` command will seed the inputs to the workflow workspace before running the workflow. Note that the property is optional.

The **inputs** property is composed of:

| Property    | Type         | Mandatory? | Description                                                                                                                      |
| --------    | ----         | ---------- | -----------                                                                                                                      |
| directories | *list*       | *optional* | Lists all the input directories to the workflow. Will be seeded to the workspace before running.                                 |
| files       | *list*       | *optional* | Lists all the input files to the workflow.  Will be seeded to the workspace before running.                                      |
| parameters  | *dictionary* | *optional* | Specifies all the input parameters to the workflow. It is a dictionary of parameter names and their values expressed as strings. |
| options     | *dictionary* | *optional* | Specifies operational options for each workflow engine, see below.                                                               |

The **inputs.options** property describes operational options that can be used for the different workflow engines. The available options are:

| Property | Type     | Mandatory?  | Workflow engine | Description                            |
| -------- | ----     | ----------  | ----------------|                                        |
| CACHE    | *string* | *optional*  | Serial          | Whether the workflow engine should cache the results of each step for faster execution of subsequent workflow runs. Disabled by default. Can be `on` or `off`. |
| FROM     | *string* | *optional*  | Serial          | Allows partial execution of a workflow starting from the beginning of a desired step. The value is the name of the desired starting step.  Note that the `FROM` option be combined with the `TARGET` option. |
| TARGET   | *string* | *optional*  | Serial, CWL     | Allows partial execution of a workflow until the end of a desired step. The value is the name of the desired target step. Note that the `TARGET` option can be combined with the `FROM` option. |
| toplevel | *string* | *optional*  | Yadage          | Yadage `toplevel` argument. It represents the working directory or remote repository where the workflow should be pulled from. [More info](https://yadage.readthedocs.io/en/latest/definingworkflows.html?highlight=toplevel#using-json-references). It supports GitHub as remote repository `github:<username/repo[@branch]>[:subpath]` |
| initdir  | *string* | *optional*  | Yadage          | Yadage `initdir` argument. It represents the initial directory for workflows running locally. |
| initfiles  | *list* | *optional*  | Yadage          | Yadage `initfiles` argument. A list of YAML files that passes initial parameters as the workflow inputs. |

The **inputs** property example:

```yaml
inputs:
  directories:
    - mydir1
    - mysubdirs/mydir2
  files:
    - myfile1.csv
    - mysubdirs/myotherdir/myfile2.csv
  parameters:
    myparam1: myvalue1
    myparam2: myvalue2
  options:
    CACHE: off
```

### reana.yaml workflow

The **workflow** property of `reana.yaml` specifies the computational steps
that are necessary to take to get the results. REANA supports three different
workflow specification languages
([CWL](/running-workflows/supported-systems/cwl),
[Serial](/running-workflows/supported-systems/serial),
[Yadage](/running-workflows/supported-systems/yadage)). Each workflow
specification language expresses the computational steps differently.

The **workflow** property is composed of:

| Property      | Type         | Mandatory?                                         | Description                                 |
| --------      | ----         | ----------                                         | -----------                                 |
| type          | *string*     | *mandatory*                                        | Specifies workflow language type. Can be `cwl`, `serial`, `yadage`. |
| file          | *string*     | *mandatory if property `specification` is missing* | For CWL and Yadage workflows, specifies workflow steps in an external file, using their respective workflow definition languages.  |
| specification | *dictionary* | *mandatory if property `file` is missing*          | For Serial workflows, specifies workflow steps internally in `reana.yaml`, see below.  |

The **workflow.specification** property is used in Serial workflows and is further composed of:

| Property | Type   | Mandatory?  | Description                                        |
| -------- | ----   | ----------  | -----------                                        |
| steps    | *list* | *mandatory* | Lists all workflow steps that are to be run sequentially to obtain workflow results. |

The **workflow.specification.steps** property describes each individual computational step of the Serial workflow and is further composed of:

| Property | Type   | Mandatory?  | Description                                        |
| -------- | ----   | ----------  | -----------                                        |
| name    | *string* | *optional* | Provides name of the given workflow step. |
| environment  | *string*  | *mandatory*  | Specifies runtime environment container image where the given workflow step commands will be run.  |
| commands  | *list*  | *mandatory*  | Lists all commands to be run in the runtime environment container image when the given workflow step is executed. Note that each command is executed as a separate containerised job. |

The **workflow** property examples:

- For [CWL](/running-workflows/supported-systems/cwl) workflows:

```yaml
workflow:
  type: cwl
  file: myworkflow.cwl
```

- For [Serial](/running-workflows/supported-systems/serial) workflows:

```yaml
workflow:
  type: serial
  specification:
    steps:
      - name: gendata
        environment: mydockerhuborganisation/mygendockerimage:1.1
        commands:
        - ./mygencommand "${mygenparam}" > mydata.txt
        - ./mygenothercommand mydata.txt > mydata.csv
      - name: fitdata
        environment: mydockerhuborganisation/myfitdockerimage:42.1
        commands:
        - ./myfitcommand mydata.csv "${myfitparam}" > myplot.png
```

- For [Yadage](/running-workflows/supported-systems/yadage) workflows:

```yaml
workflow:
  type: yadage
  file: myworkflow.yaml
```

A more detailed information on workflow specification languages is available in
corresponding [CWL](/running-workflows/supported-systems/cwl),
[Serial](/running-workflows/supported-systems/serial) and
[Yadage](/running-workflows/supported-systems/yadage) pages.

### reana.yaml outputs

The **outputs** property of `reana.yaml` specifies all the workflow high-level
outputs, consisting of a list of files and directories. The `reana-client download`
command will download all the specified files and directories from the workflow
workspace to the local filesystem. Note that the property is optional.

The **output** property is composed of:

| Property    | Type         | Mandatory? | Description                                       |
| --------    | ----         | ---------- | -----------                                       |
| files       | *list*       | *optional* | Lists all the output files of the workflow.       |
| directories | *list*       | *optional* | Lists all the output directories of the workflow. |

The **outputs** property example:

```yaml
outputs:
  files:
    - myplot.png
    - mysubdirs/myotherdir/myotherplot.pdf
  directories:
    - mydir
```

## Validating `reana.yaml`

You can use `reana-client validate` command to make sure that your `reana.yaml`
(or `reana.yml`) specification file is conform to the above standard:

```console
$ reana-client validate
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> SUCCESS: Workflow parameters and commands appear valid.
```

If your workflow specification file is not named `reana.yaml` (or `reana.yml`),
you can use the `-f` command-line option to specify the path to the file for
the validation:

```console
$ reana-client validate -f reana-debug.yaml
==> Verifying REANA specification file... my-analysis/reana-debug.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> SUCCESS: Workflow parameters and commands appear valid.
```

The `reana-client validate` command will warn you about any errors or problems
in your `reana.yaml` files.

### Validation of workflow input parameters

The `reana-client validate` command will also verify that all the defined input
parameters are being used in the workflow step commands.

For instance, if an input parameter called `myparam` is defined but it is not
used in the step commands, a warning will be displayed:

```console
$ reana-client validate
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> WARNING: REANA input parameter "myparam" does not seem to be used.
```

Similarly, it will also check that all the input parameters referenced in the step
commands are properly defined in the input parameters section:

```console
$ reana-client validate
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> WARNING: Serial parameter "myparam" found on step "gendata" is not defined in input parameters.
```

This validation is compatible with [Serial](/running-workflows/supported-systems/serial),
[Yadage](/running-workflows/supported-systems/yadage) and
[CWL](/running-workflows/supported-systems/cwl) workflows.

### Validation of workflow environment images

The `reana-client validate` command has an option `--environments` to perform
a validation of the environment images specified in the workflows steps. It will
check that the referenced images have a valid format and point at a valid tag.
It also verifies the image existence locally and remotely (Docker Hub, GitLab registry).

```console
$ reana-client validate --environments
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> SUCCESS: Workflow parameters and commands appear valid.
==> Verifying environments in REANA specification file...
  -> SUCCESS: Environment image python:2.7-slim has the correct format.
  -> SUCCESS: Environment image python:2.7-slim exists locally.
  -> SUCCESS: Environment image python:2.7-slim exists in Docker Hub.

$ reana-client validate --environments
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> SUCCESS: Workflow parameters and commands appear valid.
==> Verifying environments in REANA specification file...
  -> WARNING: Using 'latest' tag is not recommended in python environment image.
  -> SUCCESS: Environment image python:latest exists locally.
  -> SUCCESS: Environment image python:latest exists in Docker Hub.
```

If the image is available locally, it will perform some checks to verify that
the image user ID and group IDs are the expected. If it is not available locally
but it publicly available remotely, it is possible to pass the `--pull` option
to download the image and carry out these checks.

```console
$ reana-client validate --environments
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> SUCCESS: Workflow parameters and commands appear valid.
==> Verifying environments in REANA specification file...
  -> WARNING: Environment image gitlab-registry.cern.ch/jdoe/my-analysis:1.0 does not exist locally.
  -> SUCCESS: Environment image gitlab-registry.cern.ch/jdoe/my-analysis:1.0 exists in GitLab CERN.
  -> WARNING: UID/GIDs validation skipped, specify `--pull` to enable it.

$ reana-client validate --environments --pull
==> Verifying REANA specification file... my-analysis/reana.yaml
  -> SUCCESS: Valid REANA specification file.
==> Verifying workflow parameters and commands...
  -> SUCCESS: Workflow parameters and commands appear valid.
==> Verifying environments in REANA specification file...
  -> WARNING: Environment image gitlab-registry.cern.ch/jdoe/my-analysis:1.0 does not exist locally.
  -> SUCCESS: Environment image gitlab-registry.cern.ch/jdoe/my-analysis:1.0 exists in GitLab CERN.
Unable to find image 'gitlab-registry.cern.ch/jdoe/my-analysis:1.0' locally
latest: Pulling from jdoe/my-analysis
89d9c30c1d48: Pulling fs layer
...
...
  -> INFO: Environment image uses UID 0 but will run as UID 1000.
```

For concrete hands-on examples of REANA workflow validation in practice, please
see our [blog post](https://blog.reana.io/posts/2021/reana-0.7.3/) describing REANA 0.7.3 release.

## Examples

Many `reana.yaml` examples can be seen in the REANA demo example analyses:

- [reana-demo-helloworld](https://github.com/reanahub/reana-demo-helloworld) - a simple "hello world" example
- [reana-demo-worldpopulation](https://github.com/reanahub/reana-demo-worldpopulation) - a parametrised Jupyter notebook example
- [reana-demo-root6-roofit](https://github.com/reanahub/reana-demo-root6-roofit) - a simplified ROOT RooFit physics analysis example
- [reana-demo-alice-lego-train-test-run](https://github.com/reanahub/reana-demo-alice-lego-train-test-run) - ALICE experiment analysis train test run and validation
- [reana-demo-alice-pt-analysis](https://github.com/reanahub/reana-demo-alice-pt-analysis) - a simple ALICE Pt analysis demonstrator
- [reana-demo-atlas-recast](https://github.com/reanahub/reana-demo-atlas-recast) - ATLAS collaboration production software stack example recasting an analysis
- [reana-demo-bsm-search](https://github.com/reanahub/reana-demo-bsm-search) - a typical BSM search example with complex particle physics workflows
- [reana-demo-cms-h4l](https://github.com/reanahub/reana-demo-cms-h4l) - CMS Higgs-to-four-leptons open data analysis example
- [reana-demo-cms-reco](https://github.com/reanahub/reana-demo-cms-reco) - CMS RAW-to-AOD reconstruction example
- [reana-demo-lhcb-d2pimumu](https://github.com/reanahub/reana-demo-lhcb-d2pimumu) - LHCb rare charm decay search example
