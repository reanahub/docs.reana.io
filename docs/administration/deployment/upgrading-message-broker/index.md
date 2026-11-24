# Upgrading message broker

REANA uses the [RabbitMQ](https://www.rabbitmq.com/) message broker to queue the submitted workflows and to exchange their status updates.
The REANA 0.95 release series upgrades RabbitMQ from version 3.8 to version 4.4, which cannot read the data of the previous version.

The new message broker therefore starts with empty queues and stores its data in a separate directory.
If you are upgrading an existing REANA deployment, any workflow that is still queued at the time of the upgrade would remain queued forever.

## Before upgrading

1. Announce a maintenance window and make sure that users do not submit any new workflows.
2. Wait until all the queued and running workflows have finished.
3. Check that the queues are empty right before upgrading REANA:

    ```{ .console .copy-to-clipboard }
    $ kubectl exec -i -t reana-message-broker-0 -- rabbitmqctl list_queues name messages messages_unacknowledged
    Timeout: 60.0 seconds ...
    Listing queues for vhost / ...
    name    messages    messages_unacknowledged
    jobs-status    0    0
    workflow-submission    0    0
    ```

!!! warning

    Do not pause the scheduling of workflows by setting the [concurrency limits](https://github.com/reanahub/reana/tree/master/helm/reana#workflow-concurrency-limits) to `0` in order to empty the queues.
    The submitted workflows would stay in the queue and would be lost when upgrading.

## After upgrading

The new message broker creates the user that is defined by the `secrets.message_broker` Helm values.
Any other RabbitMQ users or virtual hosts that you may have created by hand are not carried over.

The data of the previous version are left in the `rabbitmq/mnesia` directory of the shared storage volume, or of the infrastructure storage volume if you have configured one, next to the directory `4` of the new version.
You can delete the `rabbit@localhost*` files and directories there once you are certain that you will not need to roll back.

## Rolling back

If you need to roll back to the previous version, please empty the queues in the same way beforehand.
The previous version of the message broker does not know the workflows that were submitted after the upgrade.
