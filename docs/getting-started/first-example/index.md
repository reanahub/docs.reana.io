# First example

First, install and activate the REANA command-line client [reana-client](https://pypi.org/project/reana-client/). For example, at CERN, login to LXPLUS and activate it as follows:

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

Second, select the REANA server, sign in through its identity provider, and test
your connection. The default opens a local browser. On a remote SSH host such
as LXPLUS, use the device flow by passing `--headless` instead:

```{ .console .copy-to-clipboard }
$ export REANA_SERVER_URL=https://reana.cern.ch
$ reana-client login --headless
$ reana-client ping
```

On a workstation with a browser, use `reana-client login` without
`--headless`.

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
