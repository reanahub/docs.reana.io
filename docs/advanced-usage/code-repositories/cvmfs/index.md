# CVMFS

If your workflow needs to access [CVMFS](https://cernvm.cern.ch/portal/filesystem)
filesystem, you should provide a ``cvmfs`` sub-clause of the ``resources`` clause that
would list all the CVMFS volumes that would be mounted for the workflow execution.
For example:

```yaml hl_lines="4 5"

    workflow:
      type: serial
      resources:
        cvmfs:
          - fcc.cern.ch
      specification:
        steps:
          - environment: 'docker.io/cern/slc6-base'
            commands:
            - ls -l /cvmfs/fcc.cern.ch/sw/views/releases/
```

> Please note that CVMFS is automatically available for HTCondor and
Slurm compute backend jobs and there is no need to specify CVMFS requirement
in the workflow specification.
