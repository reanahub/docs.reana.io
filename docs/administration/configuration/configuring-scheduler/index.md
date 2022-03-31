# Configuring workflow scheduler

## Workflow scheduling strategies

As of version 0.8, REANA supports two different workflow scheduling strategies:

- `fifo` - first-in first-out strategy starting workflows as they come.
- `balanced` - a weighted strategy taking into account existing multi-user
workloads and the [DAG](https://en.wikipedia.org/wiki/Directed_acyclic_graph) complexity of incoming workflows.

By default REANA is configured to use `fifo` workflow scheduler strategy.
If you would like to change it, you can configure
[`components.reana_server.environment.REANA_WORKFLOW_SCHEDULING_POLICY`](https://github.com/reanahub/reana/tree/master/helm/reana)
Helm value and set the desired strategy accordingly.

Note that it is also possible to change the workflow scheduler sleep time before re-inspecting
the workflow queue and launching new workflows. By default, REANA uses a sleep time of 15 seconds.
You can configure the Helm value [`components.reana_server.environment.REANA_SCHEDULER_REQUEUE_SLEEP`](https://github.com/reanahub/reana/tree/master/helm/reana).
Please don't use values lower than 2 seconds; some delay is necessary for requeuing workflows in cluster overload situations.

## Workflow scheduling readiness configuration

As of version 0.9, REANA supports the configuration of checks that are performed to
assess whether the cluster is ready to start new workflows. Possible values are:

- `0` - no readiness check; schedule new workflow as soon as they arrive;
- `1` - check for the maximum number of concurrently running workflows; schedule new workflows if not exceeded;
- `2` - check for available cluster memory size; schedule new workflow only if it fits;
- `9` - perform all checks; satisfy all previous criteria.

By default, REANA is configured to perform all checks. If you would like to
change it, you can configure
[`components.reana_server.environment.REANA_WORKFLOW_SCHEDULING_READINESS_CHECK_LEVEL`](https://github.com/reanahub/reana/tree/master/helm/reana)
Helm value and set the desired readiness check level accordingly.
