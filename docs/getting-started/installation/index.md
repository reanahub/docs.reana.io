# Installation

REANA offers two command-line clients:

- [reana-client](https://pypi.org/project/reana-client/), the Python client,
  which also provides a Python API for scripting;
- [reana-client-go](https://github.com/reanahub/reana-client-go), the Go
  client, which is a single self-contained binary.

Install a client version that matches your REANA server. For example, use a
0.9 client with a REANA 0.9 server, and a 0.95 client with a REANA 0.95
server. If you are unsure which version your server runs, ask its
administrators. At CERN (reana.cern.ch) we use the latest 0.95 server.

## Python client

### At CERN

At CERN, you can log into LXPLUS and activate a ready-made installation as
follows:

```{ .console .copy-to-clipboard }
$ source /afs/cern.ch/user/r/reana/public/reana/bin/activate
```

### Installing with pip

Otherwise, install `reana-client` via [pip](https://pip.pypa.io/en/stable/),
ideally in a new virtual environment:

```{ .console .copy-to-clipboard }
$ # create new virtual environment
$ python3 -m venv ~/.virtualenvs/reana
$ source ~/.virtualenvs/reana/bin/activate
$ # upgrade pip
$ pip install --upgrade pip
$ # install reana-client
$ pip install reana-client
```

This installs the latest stable release of `reana-client`.

### Matching an older server

If your REANA server runs an older release series, give pip a version range
for that series. For example, for a REANA 0.9 server:

```{ .console .copy-to-clipboard }
$ pip install 'reana-client>=0.9,<0.95'
```

### Installing a pre-release

If your REANA server runs a pre-release version, install a matching
pre-release of the client by giving pip a version range. For example, for a
server running a REANA 0.96 pre-release:

```{ .console .copy-to-clipboard }
$ pip install 'reana-client>=0.96.0a1,<0.97'
```

!!! tip
    Prefer a version range over `pip install --pre reana-client`. The `--pre`
    option allows pip to install pre-releases of every dependency, not only of
    `reana-client` itself.

Check the installed version with:

```{ .console .copy-to-clipboard }
$ reana-client version
```

## Go client

!!! note "REANA 0.95"
    `reana-client-go` is available as of REANA 0.95 release series.

### Downloading a binary

Each [reana-client-go release](https://github.com/reanahub/reana-client-go/releases)
publishes binaries for the following platforms:

| Platform              | Suffix         |
| --------------------- | -------------- |
| macOS (Apple silicon) | `darwin-arm64` |
| macOS (Intel)         | `darwin-amd64` |
| Linux (x86-64)        | `linux-amd64`  |
| Linux (ARM64)         | `linux-arm64`  |

Pick the release that matches your server and the suffix that matches your
platform, then download the binary and the `checksums.txt` file of the release:

```{ .console .copy-to-clipboard }
$ VERSION=v0.95.0
$ PLATFORM=darwin-arm64
$ BINARY=reana-client-go-$VERSION-$PLATFORM
$ curl -fLO https://github.com/reanahub/reana-client-go/releases/download/$VERSION/$BINARY
$ curl -fLO https://github.com/reanahub/reana-client-go/releases/download/$VERSION/checksums.txt
```

Verify the downloaded binary against the published checksum. On macOS:

```{ .console .copy-to-clipboard }
$ grep " $BINARY\$" checksums.txt | shasum -a 256 -c -
```

On Linux:

```{ .console .copy-to-clipboard }
$ grep " $BINARY\$" checksums.txt | sha256sum -c -
```

Both commands should report `OK`.

!!! note "macOS"
    The macOS binaries are not notarized by Apple. If you download a binary
    with a web browser instead of `curl`, macOS marks it as quarantined and
    refuses to run it. After verifying its checksum, remove the quarantine
    mark:

    ```{ .console .copy-to-clipboard }
    $ xattr -d com.apple.quarantine $BINARY
    ```

Then make the binary executable and move it to a directory on your `PATH`,
for example `~/.local/bin`:

```{ .console .copy-to-clipboard }
$ chmod +x $BINARY
$ mkdir -p ~/.local/bin
$ mv $BINARY ~/.local/bin/reana-client-go
$ reana-client-go version
```

If your shell cannot find `reana-client-go`, add `~/.local/bin` to your `PATH`
as follows, and add the same line to your `~/.bashrc` or `~/.zshrc` to keep
it for new shells:

```{ .console .copy-to-clipboard }
$ export PATH="$HOME/.local/bin:$PATH"
```

### Installing with Go

If you have [Go](https://go.dev/doc/install) 1.25.13 or later installed, you
can build and install the client directly, giving the release version you
want:

```{ .console .copy-to-clipboard }
$ go install github.com/reanahub/reana-client-go@v0.95.0
```

The binary is installed into `go env GOBIN`, or into `$(go env GOPATH)/bin`
when `GOBIN` is not set. Make sure that this directory is on your `PATH`.

## Next steps

Once the client is installed, continue with the [first example](../first-example)
to connect to your REANA server and run an analysis. For the Go client, use
`reana-client-go` in place of `reana-client` in the example commands.
