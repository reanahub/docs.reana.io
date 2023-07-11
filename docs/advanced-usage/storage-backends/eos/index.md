# EOS

REANA uses shared filesystem for storing results of your running workflows.
They may be garbage-collected after a certain period of time. You can use the
`reana-client download` command to download the results of your workflows or
copy them to your personal [EOS](http://information-technology.web.cern.ch/services/eos-service) space.

To publish your results on EOS you have to add a final step to your workflow
that would copy the results of interest in the outside filesystem.

First, we have to let the REANA platform know your Kerberos keytab so that the
writing is authorised. We can do this by [uploading keytab and CERN username](../../access-control/kerberos/index.md).

Second, once we have the secrets, we can use a Kerberos-aware container image
(such as [`docker.io/reanahub/krb5`](https://hub.docker.com/r/reanahub/krb5))
in the final publishing step of the workflow:

```yaml
workflow:
  type: serial
  specification:
    steps:
      - name: myfirststep
        ...
      - name: mysecondstep
        ...
      - name: publish
        kerberos: true
        environment: 'docker.io/reanahub/krb5'
        commands:
        - mkdir -p /eos/home/j/johndoe/myanalysis-outputs
        - cp myplots/*.png /eos/home/j/johndoe/myanalysis-outputs/
```

!!! note
    Note the presence of `kerberos: true` classifier in the final publishing step,
    which tells the REANA system to initialise Kerberos authentication using provided
    secrets for the workflow step at hand.
