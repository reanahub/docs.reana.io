# First example

First, install the REANA command-line client. See [installation](../installation)
for how to install the Python client `reana-client` or the Go client
`reana-client-go`. For example, at CERN, login to LXPLUS and activate it as
follows:

```{ .console .copy-to-clipboard }
$ source /afs/cern.ch/user/r/reana/public/reana/bin/activate
```

Second, log in to your REANA server and test your connection. For example, at
CERN:

```{ .console .copy-to-clipboard }
$ reana-client login --server https://reana.cern.ch
$ reana-client ping
```

Login opens your browser to authenticate, then saves the server and your
credentials for later commands. On an SSH host such as LXPLUS, add
`--headless` to authenticate through the device flow instead. For a local
development server with a self-signed certificate, add `--no-tls-verify` to
save that choice. See
[authentication and saved connections](../../reference/reana-client-cli-api/#authentication-in-reana-095)
for TLS settings, switching servers and migration from the old environment
variables.

!!! note "REANA 0.9"
    If your server still runs REANA 0.9, install a
    [matching 0.9 client](../installation/#matching-an-older-server), which
    does not have the `login` command. Instead, obtain your REANA access token
    from your profile page on the REANA web interface, then set REANA
    environment variables for the client and test your connection:

    ```{ .console .copy-to-clipboard }
    $ export REANA_SERVER_URL=https://reana.cern.ch
    $ export REANA_ACCESS_TOKEN=xxxxxxxxxxxxxxxxxxx
    $ reana-client ping
    ```

    Use your REANA 0.9 server's URL. Make sure to unset these variables when
    you move to a REANA 0.95 client. If your shell profile exports them,
    clear them with:

    ```{ .console .copy-to-clipboard }
    $ unset REANA_SERVER_URL REANA_SERVER_TLS_VERIFY REANA_ACCESS_TOKEN
    ```

Third, clone a simple [analysis example](https://github.com/reanahub/reana-demo-root6-roofit/tree/master#reana-example---root6-and-roofit) and run it on the REANA platform:

```console
$ git clone https://github.com/reanahub/reana-demo-root6-roofit
$ cd reana-demo-root6-roofit    # we now have cloned an example
$ reana-client create -w roofit # create new workflow called "roofit"
$ export REANA_WORKON=roofit    # save workflow name we are currently working on
$ reana-client upload           # upload code and inputs to remote workspace
$ reana-client start            # start the workflow
$ reana-client status           # check its status
$ # ... wait a minute or so for workflow to finish
$ reana-client status           # check whether it is finished
$ reana-client logs             # check its output logs
$ reana-client ls               # list its workspace files
$ reana-client download results/plot.png  # download output plot
```

That's it!  You should see the output plot.
