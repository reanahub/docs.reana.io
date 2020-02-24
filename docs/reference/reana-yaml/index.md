# reana.yaml

## About

REANA workflow specification file should answer 4 main questions:

* What is your input data?
* Which code analyses it?
* What is your environment?
* Which steps did you take?

You have to structure your research data analysis repository into input `data`
 and `parameters`, runtime `code`, computing `environments`, and computational
`workflows`.

## YAML syntax

REANA workflow specification uses a human-readable data-serialization language
YAML ("YAML Ain't Markup Language"). It uses Python-style indentation and supports
basic data types such as mappings, sequences, scalars.
More information can be found in [the official documentation](https://yaml.org/spec/1.2/spec.html).

## Write reana.yaml

With your favourite text editor create file `reana.yaml`

### Serial

```yaml
  version: 0.3.0
  inputs:
    files:
      - code/helloworld.py
      - data/names.txt
    parameters:
      helloworld: code/helloworld.py
      inputfile: data/names.txt
      outputfile: results/greetings.txt
      sleeptime: 0
  workflow:
    type: serial
    specification:
      steps:
        - environment: 'python:2.7-slim:tag'
          commands:
            - python "${helloworld}"
                --inputfile "${inputfile}"
                --outputfile "${outputfile}"
                --sleeptime ${sleeptime}
  outputs:
    files:
     - results/greetings.txt
```

#### Inputs & Outputs

Analysis inputs consists of two types: `files` and `parameters`.

Inputs of type `files` or `directories` will be automatically uploaded into
REANA while doing `reana-client run` or `reana-client upload`. The same applies
for section`outputs`, `reana-client download` command will automatically
download all files specified there. Files are defined in a list structure type.

Inputs of type `parameters` will be applied for the `commands` specified in the
`workflow` section. It uses a key value data structure.

#### Workflow

Workflow which represents the steps that need to be run to reproduce an analysis.

You have to specify the type of a workflow. Currently REANA supports 3 workflow
definition languages: serial, cwl, yadage.

The example above uses the `serial` workflow definition language - `type: serial`

Specification part consists of a list of steps and steps consist a list of
commands to execute. Each step must have `environment` specified - docker image
name.

#### Advanced usage

You can specify additional requirements such as [compute backend](../../advanced-usage/compute-backends/),
[CVMFS](../../advanced-usage/code-repositories/cvmfs), [kerberos access control](../../advanced-usage/access-control/kerberos#setting-kerberos-requirement)


### CWL

To be added

### YADAGE

To be added


## Validation

Your freshly created `reana.yaml` can be validated using `reana-client validate`
command.

```console

   $ reana-client validate
   File /Users/johndoe/my-analysis/reana.yaml is a valid REANA specification file.

```

If your workflow specification file is not named `reana.yaml` you have to use
`-f` flag in order to specify a file for the validation.


```console

   $ reana-client validate -f new-reana.yaml
   File /Users/johndoe/my-analysis/new-reana.yaml is a valid REANA specification file.

```
