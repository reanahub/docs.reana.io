# Configuring workflow scheduler

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
