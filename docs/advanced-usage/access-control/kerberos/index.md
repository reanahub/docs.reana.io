# Kerberos

If your workflow requires Kerberos authentication, you should set ``kerberos: true``
for the steps in need in the workflow specification. Please note that step's
docker image(e.g ``environment: 'cern/slc6-base'``) should have Kerberos client
installed and you have to [upload keytab file and username](../../compute-backends/htcondor/index.md#Authentication)  for the Kerberos authentication to work.

Serial example:

```yaml hl_lines="9"

    workflow:
      type: serial
      resources:
        cvmfs:
          - fcc.cern.ch
      specification:
        steps:
          - environment: 'cern/slc6-base'
            kerberos: true
            commands:
            - ls -l /cvmfs/fcc.cern.ch/sw/views/releases/
```

CWL example:

```yaml hl_lines="5"

    steps:
      first:
        hints:
          reana:
            kerberos: true
        run: helloworld.tool
   	    in:
   	      helloworld: helloworld

   	      inputfile: inputfile
   	      sleeptime: sleeptime
   	      outputfile: outputfile
   	    out: [result]
```

Yadage example:

```yaml hl_lines="14"

    step:
      process:
        process_type: 'string-interpolated-cmd'
        cmd: 'python "{helloworld}" --sleeptime {sleeptime} --inputfile "{inputfile}" --outputfile "{outputfile}"'
      publisher:
        publisher_type: 'frompar-pub'
        outputmap:
          outputfile: outputfile
      environment:
        environment_type: 'docker-encapsulated'
        image: 'python'
        imagetag: '2.7-slim'
        resources:
          - kerberos: true
```
