# CWL

The Common Workflow Language standard for describing computational workflows originated in the life science community. Please see:

- CWL project website: [https://www.commonwl.org](https://www.commonwl.org)
- CWL user guide: [https://www.commonwl.org/user_guide](https://www.commonwl.org/user_guide)

## Supported versions

| REANA version          | ``cwltool`` version |
| ---------------------- | ------------------- |
| 0.8 release series     | 3.1.20210628163208  |
| 0.7 release series     | 1.0.20191022103248  |
| 0.6 release series     | 1.0.20190815141648  |
| 0.5 release series     | 1.0.20181118133959  |
| 0.3 release series     | 1.0.20180912090223  |
| 0.2 release series     | 1.0.20180326152342  |

## CWL v1.0 conformance results

REANA 0.9.1 tested on 2023-12-05

- 177 tests passed
- 20 failures
- 0 unsupported features

<!-- markdownlint-disable no-inline-html  -->
<details>
    <summary>List of failed tests</summary>

```plaintext
- Test [6/197] initworkdir_expreng_requirements: Test InitialWorkDirRequirement ExpressionEngineRequirement.engineConfig feature
- Test [57/197] initial_workdir_trailingnl: Test if trailing newline is present in file entry in InitialWorkDir
- Test [65/197] format_checking_subclass: Test format checking against ontology using subclassOf.
- Test [66/197] format_checking_equivalentclass: Test format checking against ontology using equivalentClass.
- Test [87/197] directory_secondaryfiles: Test directories in secondaryFiles
- Test [100/197] filesarray_secondaryfiles: Test secondaryFiles on array of files.
- Test [103/197] dockeroutputdir: Test dockerOutputDirectory
- Test [106/197] inlinejs_req_expressions: Test InlineJavascriptRequirement with multiple expressions in the same tool
- Test [107/197] input_dir_recurs_copy_writable: Test if a writable input directory is recursively copied and writable
- Test [118/197] initial_workdir_empty_writable_docker: Test empty writable dir with InitialWorkDirRequirement inside Docker
- Test [132/197] wf_step_access_undeclared_param: Test that parameters that don't appear in the `run` process inputs are not present in the input object used to run the tool.
- Test [136/197] job_input_secondary_subdirs: Test specifying secondaryFiles in subdirectories of the job input document.
- Test [137/197] job_input_subdir_primary_and_secondary_subdirs: Test specifying secondaryFiles in same subdirectory of the job input as the primary input file.
- Test [173/197] docker_entrypoint: Test Docker ENTRYPOINT usage
- Test [192/197] no_inputs_commandlinetool: Test CommandLineTool without inputs
- Test [193/197] no_outputs_commandlinetool: Test CommandLineTool without outputs
- Test [194/197] no_inputs_workflow: Test Workflow without inputs
- Test [195/197] no_outputs_workflow: Test Workflow without outputs
- Test [196/197] anonymous_enum_in_array: Test an anonymous enum inside an array inside a record
- Test [197/197] schema-def_anonymous_enum_in_array: Test an anonymous enum inside an array inside a record, SchemaDefRequirement
```

</details>

## CWL v1.1 specification conformance results

REANA 0.9.1 tested on 2023-12-06

- 181 tests passed
- 72 failures
- 0 unsupported features

<details>
    <summary>List of failed tests</summary>

```plaintext
- Test [6/253] initworkdir_expreng_requirements: Test InitialWorkDirRequirement ExpressionEngineRequirement.engineConfig feature
- Test [57/253] initial_workdir_trailingnl: Test if trailing newline is present in file entry in InitialWorkDir
- Test [65/253] format_checking_subclass: Test format checking against ontology using subclassOf.
- Test [66/253] format_checking_equivalentclass: Test format checking against ontology using equivalentClass.
- Test [87/253] directory_secondaryfiles: Test directories in secondaryFiles
- Test [100/253] filesarray_secondaryfiles: Test required, optional and null secondaryFiles on array of files.
- Test [104/253] dockeroutputdir: Test dockerOutputDirectory
- Test [107/253] inlinejs_req_expressions: Test InlineJavascriptRequirement with multiple expressions in the same tool
- Test [108/253] input_dir_recurs_copy_writable: Test if a writable input directory is recursively copied and writable
- Test [119/253] initial_workdir_empty_writable_docker: Test empty writable dir with InitialWorkDirRequirement inside Docker
- Test [133/253] wf_step_access_undeclared_param: Test that parameters that don't appear in the `run` process inputs are not present in the input object used to run the tool.
- Test [137/253] job_input_secondary_subdirs: Test specifying secondaryFiles in subdirectories of the job input document.
- Test [138/253] job_input_subdir_primary_and_secondary_subdirs: Test specifying secondaryFiles in same subdirectory of the job input as the primary input file.
- Test [174/253] docker_entrypoint: Test Docker ENTRYPOINT usage
- Test [192/253] directory_literal_with_literal_file_nostdin: Test non-stdin reference to literal File via a Directory literal
- Test [193/253] no_inputs_commandlinetool: Test CommandLineTool without inputs
- Test [194/253] no_outputs_commandlinetool: Test CommandLineTool without outputs
- Test [195/253] no_inputs_workflow: Test Workflow without inputs
- Test [196/253] no_outputs_workflow: Test Workflow without outputs
- Test [197/253] anonymous_enum_in_array: Test an anonymous enum inside an array inside a record
- Test [198/253] schema-def_anonymous_enum_in_array: Test an anonymous enum inside an array inside a record, SchemaDefRequirement
- Test [199/253] stdin_shorcut: Test command execution in with stdin and stdout redirection using stdin shortcut
- Test [202/253] secondary_files_in_output_records: Test secondaryFiles on output record fields
- Test [204/253] secondary_files_missing: Test checking when secondaryFiles are missing
- Test [206/253] input_records_file_entry_with_format_and_bad_regular_input_file_format: Test file format checking on parameter
- Test [207/253] input_records_file_entry_with_format_and_bad_entry_file_format: Test file format checking on record field
- Test [208/253] input_records_file_entry_with_format_and_bad_entry_array_file_format: Test file format checking on array item
- Test [209/253] record_output_file_entry_format: Test format on output record fields
- Test [210/253] workflow_input_inputBinding_loadContents: Test WorkflowInputParameter.inputBinding.loadContents
- Test [211/253] workflow_input_loadContents_without_inputBinding: Test WorkflowInputParameter.loadContents
- Test [212/253] expression_tool_input_loadContents: Test loadContents on InputParameter.loadContents (expression)
- Test [213/253] workflow_step_in_loadContents: Test WorkflowStepInput.loadContents
- Test [214/253] timelimit_basic: Test that job fails when exceeding time limit
- Test [215/253] timelimit_invalid: Test invalid time limit value
- Test [216/253] timelimit_zero_unlimited: Test zero timelimit means no limit
- Test [217/253] timelimit_from_expression: Test expression in time limit
- Test [218/253] timelimit_expressiontool: Test timelimit in expressiontool is ignored
- Test [219/253] timelimit_basic_wf: Test that tool in workflow fails when exceeding time limit
- Test [220/253] timelimit_invalid_wf: Test that workflow level time limit is not applied to workflow execution time
- Test [221/253] timelimit_zero_unlimited_wf: Test zero timelimit means no limit in workflow
- Test [222/253] timelimit_from_expression_wf: Test expression in time limit in workflow
- Test [223/253] networkaccess: Test networkaccess enabled
- Test [224/253] networkaccess_disabled: Test networkaccess is disabled by default
- Test [225/253] Test null and array input in InitialWorkDirRequirement
- Test [226/253] Test array of directories InitialWorkDirRequirement
- Test [227/253] cwl_requirements_addition: Test requirements in input document via EnvVarRequirement
- Test [228/253] cwl_requirements_override_expression: Test conflicting requirements in input document via EnvVarRequirement and expression
- Test [229/253] cwl_requirements_override_static: Test conflicting requirements in input document via EnvVarRequirement
- Test [230/253] Test output of InitialWorkDir
- Test [231/253] Test if full paths are allowed in glob
- Test [232/253] Test fail trying to glob outside output directory
- Test [233/253] symlink to file outside of working directory should NOT be retrieved
- Test [234/253] symlink to file inside of working directory should be retrieved
- Test [235/253] inplace update has side effect on file content
- Test [236/253] inplace update has side effect on directory content
- Test [237/253] outputbinding_glob_directory: Test that OutputBinding.glob accepts Directories
- Test [238/253] stage_file_array: Test that array of input files can be staged to directory with entryname
- Test [239/253] stage_file_array: Test that array of input files can be staged to directory with basename
- Test [240/253] stage_file_array: Test that if array of input files are staged to directory with basename and entryname, entryname overrides
- Test [241/253] tmpdir_is_not_outdir: Test that runtime.tmpdir is not runtime.outdir
- Test [242/253] listing_default_none: Test that default behavior is 'no_listing' if not specified
- Test [243/253] listing_requirement_none: Test that 'listing' is not present when LoadListingRequirement is 'no_listing'
- Test [244/253] listing_loadListing_none: Test that 'listing' is not present when loadListing on input parameter is 'no_listing'
- Test [245/253] listing_requirement_shallow: Test that 'listing' is present in top directory object but not subdirectory object when LoadListingRequirement is 'shallow_listing'
- Test [246/253] listing_loadListing_shallow: Test that 'listing' is present in top directory object but not subdirectory object when loadListing on input parameter loadListing is 'shallow_listing'
- Test [247/253] listing_requirement_deep: Test that 'listing' is present in top directory object and in subdirectory objects when LoadListingRequirement is 'deep_listing'
- Test [248/253] listing_loadListing_deep: Test that 'listing' is present in top directory object and in subdirectory objects when input parameter loadListing is 'deep_listing'
- Test [249/253] inputBinding_position_expr: Test for expression in the InputBinding.position field; also test using emoji in CWL document and tool output
- Test [250/253] outputEval_exitCode: Can access exit code in outputEval
- Test [251/253] any_input_param_graph_no_default: Test use of $graph without specifying which process to run
- Test [252/253] any_input_param_graph_no_default_hashmain: Test use of $graph without specifying which process to run, hash-prefixed "main"
- Test [253/253] optional_numerical_output_returns_0_not_null: Test that optional number output is returned as 0, not null```
```

</details>

## CWL v1.2 specification conformance results

REANA 0.8.0 tested on 2022-01-12

- 254 tests passed
- 82 failures
- 0 unsupported features

<details>
    <summary>List of failed tests</summary>

```plaintext
- Test [6/336] initworkdir_expreng_requirements: Test InitialWorkDirRequirement ExpressionEngineRequirement.engineConfig feature
- Test [58/336] initial_workdir_trailingnl: Test if trailing newline is present in file entry in InitialWorkDir
- Test [66/336] format_checking_subclass: Test format checking against ontology using subclassOf.
- Test [67/336] format_checking_equivalentclass: Test format checking against ontology using equivalentClass.
- Test [88/336] directory_secondaryfiles: Test directories in secondaryFiles
- Test [101/336] filesarray_secondaryfiles: Test required, optional and null secondaryFiles on array of files.
- Test [105/336] dockeroutputdir: Test dockerOutputDirectory
- Test [108/336] inlinejs_req_expressions: Test InlineJavascriptRequirement with multiple expressions in the same tool
- Test [109/336] input_dir_recurs_copy_writable: Test if a writable input directory is recursively copied and writable
- Test [120/336] initial_workdir_empty_writable_docker: Test empty writable dir with InitialWorkDirRequirement inside Docker
- Test [134/336] wf_step_access_undeclared_param: Test that parameters that don't appear in the `run` process inputs are not present in the input object used to run the tool.
- Test [138/336] job_input_secondary_subdirs: Test specifying secondaryFiles in subdirectories of the job input document.
- Test [139/336] job_input_subdir_primary_and_secondary_subdirs: Test specifying secondaryFiles in same subdirectory of the job input as the primary input file.
- Test [175/336] docker_entrypoint: Test Docker ENTRYPOINT usage
- Test [205/336] secondary_files_missing: Test checking when secondaryFiles are missing
- Test [207/336] input_records_file_entry_with_format_and_bad_regular_input_file_format: Test file format checking on parameter
- Test [208/336] input_records_file_entry_with_format_and_bad_entry_file_format: Test file format checking on record field
- Test [209/336] input_records_file_entry_with_format_and_bad_entry_array_file_format: Test file format checking on array item
- Test [210/336] record_output_file_entry_format: Test format on output record fields
- Test [215/336] timelimit_basic: Test that job fails when exceeding time limit
- Test [218/336] timelimit_from_expression: Test expression in time limit
- Test [220/336] timelimit_basic_wf: Test that tool in workflow fails when exceeding time limit
- Test [223/336] timelimit_from_expression_wf: Test expression in time limit in workflow
- Test [225/336] networkaccess_disabled: Test networkaccess is disabled by default
- Test [226/336] Test null and array input in InitialWorkDirRequirement
- Test [228/336] cwl_requirements_addition: Test requirements in input document via EnvVarRequirement
- Test [229/336] cwl_requirements_override_expression: Test conflicting requirements in input document via EnvVarRequirement and expression
- Test [230/336] cwl_requirements_override_static: Test conflicting requirements in input document via EnvVarRequirement
- Test [233/336] Test fail trying to glob outside output directory
- Test [234/336] symlink to file outside of working directory should NOT be retrieved
- Test [235/336] symlink to file inside of working directory should be retrieved
- Test [236/336] inplace update has side effect on file content
- Test [237/336] inplace update has side effect on directory content
- Test [239/336] stage_file_array: Test that array of input files can be staged to directory with entryname
- Test [240/336] stage_file_array: Test that array of input files can be staged to directory with basename
- Test [241/336] stage_file_array: Test that if array of input files are staged to directory with basename and entryname, entryname overrides
- Test [250/336] inputBinding_position_expr: Test for expression in the InputBinding.position field; also test using emoji in CWL document and tool output
- Test [251/336] outputEval_exitCode: Can access exit code in outputEval
- Test [257/336] escaping: Line continuations in bash scripts should behave correctly
- Test [258/336] escaping: Line continuations in bash scripts should always behave correctly
- Test [259/336] escaping: Test quoting multiple backslashes
- Test [260/336] quotes: Strings returned from JS expressions should not have extra quotes around them
- Test [267/336] first_non_null_all_null: pickValue: first_non_null needs at least one non null
- Test [270/336] pass_through_required_fail: pickValue: the_only_non_null will fail due to multiple non nulls
- Test [271/336] all_non_null_multi_with_non_array_output: pickValue: all_non_null will fail validation
- Test [273/336] the_only_non_null_multi_true: pickValue: the_only_non_null will fail with two active nodes
- Test [281/336] conditionals_non_boolean_fail: Non-boolean values from "when" should fail
- Test [289/336] first_non_null_all_null_nojs: pickValue: first_non_null needs at least one non null; no javascript
- Test [292/336] pass_through_required_fail: pickValue: the_only_non_null will fail due to multiple non nulls; no javascript
- Test [293/336] all_non_null_multi_with_non_array_output_nojs: pickValue: all_non_null will fail validation; no javascript
- Test [295/336] the_only_non_null_multi_true_nojs: pickValue: the_only_non_null will fail with two active nodes; no javascript
- Test [301/336] scatter_on_scattered_conditional_nojs: Simple scatter: Add conditional variable to scatter; no javascript
- Test [302/336] conditionals_nested_cross_scatter_nojs: nested cross product scatter with condition on one dimension; no javascript
- Test [303/336] conditionals_non_boolean_fail_nojs: Non-boolean values from "when" should fail; no javascript
- Test [304/336] conditionals_multi_scatter_nojs: Scatter two steps, flatten result + pickValue; no javascript
- Test [305/336] Default inputs, choose step to run based on what was provided, first case
- Test [306/336] Default inputs, choose step to run based on what was provided, second case
- Test [307/336] Confirm CommandInputParameter expression can receive a File object
- Test [309/336] test v1.0 workflow document that runs other versions
- Test [310/336] test v1.1 workflow document that runs other versions
- Test [311/336] test v1.2 workflow document that runs other versions
- Test [312/336] test tool with v1.2 syntax marked as v1.0 (should fail)
- Test [313/336] test tool with v1.2 syntax marked as v1.1 (should fail)
- Test [316/336] test 1.2 wf that includes tools that are marked as v1.0 and v1.1 that
- Test [319/336] Test that InitialWorkDir contents can be bigger than 64k
- Test [320/336] Test dump object to JSON in InitialWorkDir file contents, no trailing newline
- Test [321/336] Test dump object to JSON in InitialWorkDir file contents, with trailing newline
- Test [322/336] Test array to JSON in InitialWorkDir file contents, no trailing newline
- Test [323/336] Test array to JSON in InitialWorkDir file contents, with trailing newline
- Test [324/336] Test number to JSON in InitialWorkDir file contents, no trailing newline
- Test [325/336] Test number to JSON in InitialWorkDir file contents, with trailing newline
- Test [326/336] Test InitialWorkDir file passthrough
- Test [327/336] Test InitialWorkDir file object is serialized to json
- Test [328/336] Test InitialWorkDir file object is passed through
- Test [329/336] Test InitialWorkDir file object is passed through
- Test [330/336] Test File and Directory object in listing
- Test [331/336] Test File and Directory object in listing
- Test [332/336] Test input mount locations when container required
- Test [333/336] Test input mount locations when no container (should fail)
- Test [334/336] Test input mount locations when container is a hint (should fail)
- Test [335/336] Must fail if entryname starts with ../
- Test [336/336] Test directory literal containing a real file
```

</details>
<!-- markdownlint-enable no-inline-html  -->
