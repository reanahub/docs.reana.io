# EOS

REANA uses shared filesystem for storing results of your running workflows.
They may be garbage-collected after a certain period of time. You can use the
`reana-client download` command to download the results of your workflows.

If you wish to automatise the copying of your workflow outputs to your personal
[EOS](http://information-technology.web.cern.ch/services/eos-service) space,
you can proceed as follows.

First, you will have to let the REANA platform know your Kerberos keytab so
that the writing to EOS would be authorised. We can do this by [creating and
uploading keytab and CERN username](../../access-control/kerberos/index.md) as
your user secrets.

Second, once your Kerberos user secrets are uploaded to the REANA platform, you
can modify your workflow to add a final data publishing step that would copy
your output plots to the desired EOS directory. For example:

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
        environment: 'docker.io/library/ubuntu:20.04'
        kerberos: true
        commands:
          - mkdir -p /eos/home-j/johndoe/myanalysis-outputs
          - cp myplots/*.png /eos/home-j/johndoe/myanalysis-outputs/
```

Note the presence of the ``kerberos: true`` clause in the final publishing step
definition which instructs the REANA system to initialise the Kerberos-based
authentication process using the provided user secrets.
