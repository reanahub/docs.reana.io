# First example

First, obtain your REANA command-line access token from your profile page.
The following steps use the REANA 0.9 authentication method used by current
production deployments. For example, at CERN, open:

```{ .console .copy-to-clipboard }
$ firefox https://reana.cern.ch
```

Second, install and activate the REANA command-line client [reana-client](https://pypi.org/project/reana-client/). For example, at CERN, login to LXPLUS and activate it as follows:

```{ .console .copy-to-clipboard }
$ source /afs/cern.ch/user/r/reana/public/reana/bin/activate
```

Alternatively, you can install it via [pip](https://pip.pypa.io/en/stable/), ideally in a new virtual environment:

```{ .console .copy-to-clipboard }
$ # create new virtual environment
$ virtualenv ~/.virtualenvs/reana
$ source ~/.virtualenvs/reana/bin/activate
$ # upgrade pip
$ pip install --upgrade pip
$ # install reana-client
$ pip install reana-client
```

Third, set REANA environment variables for the client (using the access token obtained in the first step) and test your connection:

```{ .console .copy-to-clipboard }
$ export REANA_SERVER_URL=https://reana.cern.ch
$ export REANA_ACCESS_TOKEN=xxxxxxxxxxxxxxxxxxx
$ reana-client ping
```

!!! note "REANA 0.95"
    As of REANA 0.95 release series, use `reana-client login --server URL`
    instead of obtaining and exporting a REANA access token. Use a client
    that matches your server; for an unreleased server, use the corresponding
    development client checkout. The environment-variable setup in the third
    step is not needed. Clear any old exports your shell profile may already
    set, then log in:

    ```{ .console .copy-to-clipboard }
    $ unset REANA_SERVER_URL REANA_SERVER_TLS_VERIFY REANA_ACCESS_TOKEN
    $ reana-client login --server https://reana.example.org
    $ reana-client ping
    ```

    Use your REANA 0.95 server's URL. Login saves the server and credentials
    for later commands. On an SSH host such as LXPLUS, add `--headless` to
    authenticate through the device flow. For a local development server
    with a self-signed certificate, add `--no-tls-verify` to save that choice.
    See [authentication and saved connections](../../reference/reana-client-cli-api/#authentication-in-reana-095)
    for TLS settings, switching servers and migration from the old exports.
    Continue with the same workflow commands below after login.

Fourth, clone a simple [analysis example](https://github.com/reanahub/reana-demo-root6-roofit/tree/master#reana-example---root6-and-roofit) and run it on the REANA platform:

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
