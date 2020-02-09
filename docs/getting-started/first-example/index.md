# First example

First, obtain your new REANA command-line access token. For example, at CERN, do:

```console
$ firefox https://reana.cern.ch
```

Second, install and activate the REANA command-line client [reana-client](https://pypi.org/project/reana-client/). For example, at CERN, login to LXPLUS and activate it as follows:

```console
$ source ~simko/public/reana/bin/activate
```

Third, set REANA environment variables for the client (using the access token obtained in the first step) and test your connection:

```console
$ export REANA_SERVER_URL=https://reana.cern.ch
$ export REANA_ACCESS_TOKEN=xxxxxxxxxxxxxxxxxxx
$ reana-client ping
```

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
