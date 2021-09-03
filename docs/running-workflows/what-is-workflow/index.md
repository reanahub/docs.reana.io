# What is a workflow?

Workflows describe which computational steps were taken to run an analysis.

## Simple workflows

Let us assume that our analysis is run in two stages, firstly a data filtering stage and secondly a data plotting stage. A hypothetical example:

```console
$ python ./code/mycode.py \
    < ./data/mydata.csv > ./workspace/mydata.tmp
$ python ./code/mycode.py --plot myparameter=myvalue \
    < ./workspace/mydata.tmp > ./results/myplot.png
```

Note how we call a given sequence of commands to produce our desired output plots. In order to capture this sequence of commands in a “runnable” or “actionable” manner, we can write a short shell script `run.sh` and make it parametrisable:

```console
$ ./run.sh --myparameter myvalue
```

In this case you will want to use the [Serial](../supported-systems/serial) workflow engine of REANA. The engine permits to express the workflow as a sequence of commands:

```console
    START
     |
     |
     V
+--------+
| filter |  <-- mydata.csv
+--------+
     |
     | mydata.tmp
     |
     V
+--------+
|  plot  |  <-- myparameter=myvalue
+--------+
     |
     | plot.png
     V
    STOP
```

Note that you can run different commands in different computing environments, but they must be run in a linear sequential manner.

The sequential workflow pattern will usually cover only simple computational workflow needs.

## Complex workflows

For advanced workflow needs we may want to run certain commands in parallel in a sort of map-reduce fashion. There are [many workflow systems](https://github.com/common-workflow-language/common-workflow-language/wiki/Existing-Workflow-systems) that are dedicated to expressing complex computational schemata in a structured manner. REANA supports several, such as [CWL](../supported-systems/cwl), [Yadage](../supported-systems/yadage) and [Snakemake](../supported-systems/snakemake).

The workflow systems enable to express the computational steps in the form of [Directed Acyclic Graph (DAG)](https://en.wikipedia.org/wiki/Directed_acyclic_graph) permitting advanced computational scenarios.

```console
              START
               |
               |
        +------+----------+
       /       |           \
      /        V            \
+--------+  +--------+  +--------+
| filter |  | filter |  | filter |   <-- mydata
+--------+  +--------+  +--------+
        \       |       /
         \      |      /
          \     |     /
           \    |    /
            \   |   /
             \  |  /
              \ | /
            +-------+
            | merge |
            +-------+
                |
                | mydata.tmp
                |
                V
            +--------+
            |  plot  |  <-- myparameter=myvalue
            +--------+
                |
                | plot.png
                V
               STOP
```

You can take inspiration from the existing [examples](https://github.com/reanahub/?q=reana-demo).
