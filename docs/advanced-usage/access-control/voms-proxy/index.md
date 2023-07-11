# VOMS proxy

## About VOMS

The Virtual Organization Membership Service
([VOMS](https://italiangrid.github.io/voms/index.html)) is at the core of the
authorisation stack of the Worldwide LHC Computing Grid
([WLCG](https://wlcg.web.cern.ch/)).

VOMS provides information about the relationship between researchers and their
Virtual Organizations (VOs). The VOs manage users and grant them permissions
according to their groups and roles. At CERN, all the various experimental
collaborations such as ALICE, ATLAS, CMS and LHCb have their own VO. Being part
of a VO can give you access to the globally distributed data analysis
infrastructure of the collaboration.

If your workflow needs special data access rights using permissions granted by
your Virtual Organization, you can use the VOMS proxy authentication technique
with your REANA workflows as described in detail below.

## Testing your credentials

If you do not have a user certificate yet, please create one at
[ca.cern.ch/ca](https://ca.cern.ch/ca/) and generate your `usercert.pem` and
`userkey.pem` following [voms-proxy-init
documentation](https://ca.cern.ch/ca/Help/?kbid=024010).

Please check that your credentials are working well on LXPLUS. Start by logging
in to LXPLUS:

```console
$ ssh johndoe@lxplus.cern.ch
```

Make sure that your `userkey.pem` is read-write accessible only by you as the
file owner:

```console
$ ls -l ~/.globus
-rw-------. usercert.pem
-rw-------. userkey.pem
```

Try to create a VOMS proxy certificate for your Virtual Organization:

```console
$ voms-proxy-init --voms cms
Enter GRID pass phrase for this identity:

Contacting voms2.cern.ch:15002 [/DC=ch/DC=cern/OU=computers/CN=voms2.cern.ch]...

Remote VOMS server contacted succesfully.

Created proxy in /tmp/x509up_u131816.

Your proxy is valid until Wed Apr 01 00:43:08 CEST 2020
```

If these steps succeed, you are ready to use the VOMS proxy authentication
technique with REANA.

## Uploading secrets

### Client-side proxy generation

We recommend to create your VOMS proxy file on the client-side, such as on your
laptop, exactly as you would do when using LXPLUS.

The proxy file can be generated on the client side as follows:

```console
$ voms-proxy-init --cert ~/.globus/usercert.pem \
                  --key ~/.globus/userkey.pem \
                  --voms cms
...

Created proxy in /tmp/x509up_u1000.

Your proxy is valid until Wed Oct 12 02:18:30 CEST 2022
```

You will now need to upload the created proxy file to the REANA cluster as a
personal secret, as well as specify the name of the desired Virtual
Organization that you would like to use:

```console
$ reana-client secrets-add --env VONAME=cms \
                           --env VOMSPROXY_FILE=x509up_u1000 \
                           --file /tmp/x509up_u1000
```

Note that the generated proxy file has a certain temporal validity, such as 24
hours. You may therefore need to regenerate and reupload the proxy file from
time to time, for example each time before you submit a new workflow run after
being idle for a few days. Whilst the client-side proxy file regeneration and
reupload procedure may be a little inconvenient, it helps to strengthen your
online safety, since your user certificate and key never leave your laptop.

Please proceed to the section entitled [Configuring your
workflows](/advanced-usage/access-control/voms-proxy/#configuring-your-workflows)
below to see how to configure your workflows to use the uploaded VOMS proxy
file resource in your runtime jobs.

### Server-side proxy generation

If you would like REANA to automatically create the proxy file for your
workflow jobs on the server side, rather than doing it yourself on the client
side as described above, then REANA would need to access your (i) user
certificate `usercert.pem`, (ii) encrypted private key `userkey.pem`, and (iii)
the Grid passphrase encoded using the base64 encoding.

If your Grid passphrase is `mygridpassphrase`, you would generate the
corresponding base64-encoded value as follows:

```console
$ echo -n 'mygridpassphrase' | base64
bXlncmlkcGFzc3BocmFzZQ==
```

Thusly encoded passphrase will be expected as the `VOMSPROXY_PASS` environment
variable user secret.

Finally, REANA would also need to know (iv) which VO you would like to use,
such as "atlas" or "cms". This should be specified in the environment variable
`VONAME`.

These four secrets necessary for server-side generation of VOMS proxy file can
be uploaded to REANA as follows:

```console
$ reana-client secrets-add --file userkey.pem \
                           --file usercert.pem \
                           --env VOMSPROXY_PASS=bXlncmlkcGFzc3BocmFzZQ== \
                           --env VONAME=cms
```

In this way, REANA will be able to generate the proxy file automatically
whenever a workflow runtime job needs it, so that the proxy file will be
"always fresh", unlike the client-side technique where the proxy would expire
after a certain time period and would need to be regenerated and reuploaded by
the client.

!!! important

    Please use this technique only on REANA clusters that you trust, for
    example if you are using a single-user REANA deployment on your premises
    and if you have full control over your cluster. If you are using a
    multi-user REANA deployment, where other persons could have admin access to
    the Kubernetes cluster you are using, the client-side generation technique
    described in the previous paragraph should be preferred for online safety
    reasons. Your user certificate, your key and encoded passphrase should
    never leave your laptop to untrusted clusters in order to reduce the risk
    of attempts at impersonating you.

## Configuring your workflows

You are now ready to declare that some steps of your workflow need VOMS proxy
to access restricted data. This can be achieved by setting the workflow hint
called `voms_proxy` for those steps. The examples below show how to specify
this hint for your CWL, Serial, Snakemake and Yadage workflows.

CWL workflow example:

```yaml hl_lines="3 4 5"
steps:
  first:
    hints:
      reana:
        voms_proxy: true
    run: my_xrdcp_step.tool
```

Serial workflow example:

```yaml hl_lines="6"
workflow:
  type: serial
  specification:
    steps:
      - environment: docker.io/johndoe/myanalysisenvironment:1.0
        voms_proxy: true
        commands:
          - xrdcp root://example.org//mydata.root .
```

Snakemake example:

```yaml hl_lines="4 5"
rule mystep:
  container:
    "docker://docker.io/johndoe/myanalysisenvironment:1.0"
  resources:
    voms_proxy=True
  shell:
    "xrdcp root://example.org//mydata.root ."
```

Yadage example:

```yaml hl_lines="13 14"
step:
  process:
    process_type: "string-interpolated-cmd"
    cmd: 'xrdcp root://example.org//mydata.root .'
  publisher:
    publisher_type: "frompar-pub"
    outputmap:
      outputfile: outputfile
  environment:
    environment_type: "docker-encapsulated"
    image: "docker.io/johndoe/myanalysisenvironment"
    imagetag: "1.0"
    resources:
      - voms_proxy: true
```

The `voms_proxy` workflow hint is fully sufficient to instruct REANA to set up
the VOMS proxy authentication for your jobs. You don't have to modify the logic
of your workflow steps in any other way besides providing the above one-line
workflow hint declarations.

## Creating your job environment images

In the above examples, we have used
`docker.io/johndoe/myanalysisenvironment:1.0` as an example of the job
environment container image that would be used at runtime to execute the
workflow step that is accessing some VO restricted resource. When REANA will
orchestrate the execution of this job, it will automatically create a sidecar
container that will perform the necessary VOMS proxy authentication beforehand,
using the secrets you uploaded. In some cases, this may already be sufficient
for your VO restricted resource usage needs.

However, if you would like to access restricted data located on a remote Grid
site, your job is expected to have local access to the Grid site certificates
for the authentication verification to work. It is the responsibility of your
job container image to provide `xrdcp` tools and any remote Grid site
certificates that may be needed for the execution of your workflow. REANA's
VOMS proxy sidecar container only takes care of establishing the VOMS proxy
authentication. Therefore, you may need to check whether your job images
contain all the necessary tools to work with remote Grid sites.

For example, let us assume that you are an ATLAS physicist who uses
`atlas/analysisbase:21.2.130` as the base job environment image for your
analysis. This image uses a special "atlas" user and is based on the CentOS
Linux 7 distribution:

```console
$ docker run -i -t --rm docker.io/atlas/analysisbase:21.2.130 /usr/bin/id
uid=1000(atlas) gid=1000(atlas) groups=1000(atlas),10(wheel)

$ docker run -i -t --rm docker.io/atlas/analysisbase:21.2.130 /bin/bash -c 'cat /etc/redhat-release'
CentOS Linux release 7.7.1908 (Core)
```

However, the image does not contain any Grid certificates. For example, the
German Grid sites certificates are missing:

```console
$ docker run -i -t --rm docker.io/atlas/analysisbase:21.2.130 /bin/bash -c 'ls -l /etc/grid-security/certificates/GermanGrid.pem'
ls: cannot access /etc/grid-security/certificates/GermanGrid.pem: No such file or directory
```

This may lead to problems accessing German Grid sites in your workflows, even
if the VOMS proxy authentication worked well. If you would like to access
remote data located on a German grid site, then you should enrich your job
environment image by amending `Dockerfile` as follows:

```console
$ cat Dockerfile
FROM docker.io/atlas/analysisbase:21.2.130
USER root
RUN curl -o /etc/yum.repos.d/EGI-trustanchors.repo https://repository.egi.eu/sw/production/cas/1/current/repo-files/EGI-trustanchors.repo && \
    yum -y install ca-certificates ca-policy-egi-core wlcg-voms-atlas && \
    yum -y clean all
USER atlas
$ docker build -t docker.io/johndoe/myanalysisenvironment:1.0 .
```

Installing packages such as `ca-policy-egi-core` and `wlcg-voms-atlas` will
make sure that all the necessary Grid certificates and tools are present in the
environment image during its runtime execution.

We can verify the produced image as follows:

```console
$ docker run -i -t --rm docker.io/johndoe/myanalysisenvironment:1.0 /bin/bash -c 'ls -l /etc/grid-security/certificates/GermanGrid.pem'
-rw-r--r--. 1 root root 1407 Mar 30 11:18 /etc/grid-security/certificates/GermanGrid.pem

$ docker run -i -t --rm docker.io/johndoe/myanalysisenvironment:1.0 /bin/bash -c 'rpm -qa | grep ca_German'
ca_GermanGrid-1.116-1.noarch
```

Now the workflow steps using the `voms_proxy` hint and accessing remote restricted
data from German Grid sites should succeed.
