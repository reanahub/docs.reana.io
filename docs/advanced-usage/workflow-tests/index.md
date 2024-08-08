
# Workflow tests

The `reana-client test` command is used to test properties of REANA workflows, like the presence of certain files in the workspace, the size of the workspace, or the duration of the workflow run. Tests are defined in feature files, which are written in the Gherkin language. This helps to ensure that the workflow behaves as expected, helps to ensure reproducibility, and facilitates behaviour-driven development

## Feature files

Feature files are used to define the properties that should be tested. They are written in the Gherkin language, which is an easy to understand, human-readable format. Full documentation on feature files is available [here](https://continuous-reuse.docs.cern.ch/#anatomy-of-a-feature-file).

Test files can be specified in the `reana.yaml` specification file, or passed as arguments to the `reana-client test` command. The command will run the tests defined in the feature files, and return the status (pass/fail) of each test scenario.

## Command syntax

```{ .console .copy-to-clipboard }
$ reana-client test -w <name-of-workflow> -n <test.feature> -n <test2.feature>
```

### Options

- `-w`, `--workflow` : Name of the workflow to test
- `-n`, `--test-files` : Name of the test files to run
- `--help` : Show help message and exit

### Test file specification

For the command to detect the test files in `reana.yaml`, they must be specified at the time of the creation of the workflow you wish to test, as test file paths are associated with workflow runs. Local edits can be made to these specified files, and the tests will be run on the edited files.

If the test files are given in `reana.yaml` _and_ passed as arguments, the command will only run the tests specified in the arguments.

Example of reana.yaml, where the test files are found in the `tests` directory:

```yaml
...
tests:
    files:
        - tests/test1.feature
        - tests/test2.feature
```

## Example

Continuing from the [first example](../first-example), we can add a test to ensure that the workflow produces the expected output at all steps. This would be a good indication that something is going right, and that the workflow is behaving as expected.

Based on the specific analysis found [here](https://github.com/reanahub/reana-demo-root6-roofit/), we see that when the workflow is finished, the workspace should include `code/gendata.C` and `code/fitdata.C` (meaning the inputs were successfully uploaded), and `results/plot.png` (meaning an output was produced). We will also check that these files are a reasonable and expected size, so are likely correct.

This is straightforwardly translated into a test file (`tests/workspace-files.feature`) as follows:

```gherkin
Feature: Workspace files
    Scenario: Input files are present
        When the workflow is finished
        Then the workspace should include "code/gendata.C"
        And the workspace should include "code/fitdata.C"
    Scenario: Workflow produces final plot
        When the workflow is finished
        Then the workspace should include "results/plot.png"
    Scenario: Files are a reasonable size
        When the workflow is finished
        Then the workspace size should be more than 150KiB
        And the workspace size should be less than 200KiB
```

This could be combined into a single scenario, but it is a good idea to seperate different concerns into different scenarios, as this makes it easier to identify the source of a failure.

Then, add the following to the end of the `reana.yaml` file:

```yaml
tests:
    files:
        - tests/workspace-files.feature
```

Run the workflow:

```{ .console .copy-to-clipboard }
$ reana-client run -w my-roofit-analysis
```

This uploads the specification, as well as the input and test files, to the REANA server.

Finally, run the test:

```{ .console .copy-to-clipboard }
$ reana-client test -w my-roofit-analysis
```

The output will show the status (pass/fail) of each test scenario. If the test fails, the reason for the failure will be displayed.

Example output:

```{ .console .copy-to-clipboard }
==> Testing file "tests/workspace-files.feature"...
  -> SUCCESS: Scenario "Input files are present"
  -> SUCCESS: Scenario "Workflow produces final plot"
  -> SUCCESS: Scenario "Files are a reasonable size"

3 passed, 0 failed in 2s
```

If, after the workflow has been run, you want to test a different set of properties (for example, to ensure the workflow completes in a certain amount of time), you can specify the test files as arguments to the `reana-client test` command. This allows you to test different properties without having to re-run the workflow.

```{ .console .copy-to-clipboard }
$ reana-client test -w my-roofit-analysis -n tests/duration.feature
```
