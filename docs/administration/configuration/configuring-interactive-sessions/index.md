# Configuring interactive sessions

## Auto-closure of inactive sessions

REANA administrators have a possibility to configure the maximum inactivity period after which
the inactive interactive sessions of users will be automatically closed. This helps to ensure
that unused sessions are not consuming resources unnecessarily.

The automatic closure of interactive sessions in REANA can be customized by configuring
[Helm values](https://github.com/reanahub/reana/tree/master/helm/reana):

- `interactive_sessions.maximum_inactivity_period`:
  This option allows you to set a limit (in days) for the maximum inactivity period for interactive
  sessions opened by the users after which they will be closed automatically.
  If this option is set to `forever`, interactive sessions will be
  kept open indefinitely unless manually closed (this the default value).

- `interactive_sessions.cronjob_schedule`:
  This option allows you to define how often the cleanup process should be scheduled, using a [cron expression](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#schedule-syntax).

For example, this is how you would configure the Helm chart to make REANA automatically close
interactive sessions that have been inactive for more than 7 days, and perform the cleanup
check every day at 03:00:

```{.yaml .copy-to-clipboard}
interactive_sessions:
    maximum_inactivity_period: 7
    cronjob_schedule: "0 3 * * *"
```

!!! tip
    Note that as an administrator you can also force the manual closure of opened interactive sessions
    regardless of the value of `interactive_sessions.maximum_inactivity_period` by means of the `reana-admin` tool.
    For example, to close any interactive session that has been inactive since 30 days, you would run:

    ```console
    $ kubectl exec -i -t deployment/reana-server -- flask reana-admin interactive-session-cleanup --days 30 --admin-access-token $REANA_ACCESS_TOKEN
    Interactive session 'reana-run-session-69d590c3-ce47-4ae1-8719-bf8952627b37-c7djf67l' has been closed.
    Interactive session 'reana-run-session-69d590c3-ce47-4ae1-8719-bf8952627b37-c7djf67l' was updated 2 days ago. Leaving opened.
    ```
