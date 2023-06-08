# Opening sessions

## Jupyter notebooks based sessions

### Open from command line

You can open Jupyter notebook sessions from the REANA-Client as follows:

```console
$ reana-client open jupyter -w helloworld
==> SUCCESS: Interactive session opened successfully
https://reana.cern.ch/f8be55e4-5d18-43f9-b977-f773fdcab163?token=<your-reana-token>
It could take several minutes to start the interactive session.
Please note that it will be automatically closed after 7 days of inactivity.
```

By clicking on the link you will have access to a Jupyter notebook interface:

![jupyter-notebook](../../images/interactive-session-jupyter-notebook.png){.screenshot-browser-mockup}

By default, newly opened sessions will use the
[`jupyter/scipy-notebook:notebook-6.4.5`](https://hub.docker.com/layers/jupyter/scipy-notebook/notebook-6.4.5/images/sha256-b6a4ce777b837496d5612b7ce4efba9aa015576cb6993817721b8d293a7c2a3c?context=explore)
Docker image to spawn your notebook.
If you would like to use a different image, you can pass it to the previous command with the
`-i/--image` option:

```console
$ reana-client open -w jupyter --image jupyter/scipy-notebook:notebook-6.4.7
==> SUCCESS: Interactive session opened successfully
https://reana.cern.ch/f8be55e4-5d18-43f9-b977-f773fdcab163?token=<your-reana-token>
It could take several minutes to start the interactive session.
Please note that it will be automatically closed after 7 days of inactivity.
```

If you want to use a custom image, please note that it has to be based on one of the
[official Jupyter images](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-base-notebook)
(in this way, it will have Jupyter running on the port `8888` and the
[`start-notebook.sh`](https://github.com/jupyter/docker-stacks/blob/main/base-notebook/start-notebook.sh) script available).

!!! warning
    REANA administrators can configure REANA to automatically close
    inactive interactive sessions after a given period of inactivity.
    As shown in the previous examples, when you start an interactive session,
    you will be informed about how long your inactive sessions will be kept open before they are
    automatically closed. You can read more about this in the [closing sessions](../closing-sessions#auto-closure-of-inactive-sessions) section.

### Open from web interface

Alternatively, you can also open Jupyter notebook sessions from the
REANA web interface by going through a list of your workflows,
clicking on the vertical ellipsis menu on the right-hand-side, and
selecting "Open Jupyter Notebook":

![ui-open-session](../../images/ui-open-session.png){.screenshot-browser-mockup}

When a workflow has an associated Jupyter notebook session opened, a
Jupyter icon will appear next to the workflow name; you can then click
on it to access the notebook.
