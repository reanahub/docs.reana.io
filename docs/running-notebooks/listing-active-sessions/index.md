# Listing active sessions

You can list the active Jupyter notebook sessions from the REANA
command-line client [reana-client](https://pypi.org/project/reana-client/)
using the `list` command with the `-s/--sessions` option:

```console
$ reana-client list --sessions
NAME         RUN_NUMBER   CREATED               SESSION_TYPE   SESSION_URI                                                                           SESSION_STATUS
jupyter      1            2021-12-01T14:33:26   jupyter        https://reana.cern.ch/f8be55e4-5d18-43f9-b977-f773fdcab163?token=<your-reana-token>   created
```

The command output will list all active sessions, the workflow names for
which the sessions were opened, as well as the session URI that you can
open in your browser to connect to the session.
