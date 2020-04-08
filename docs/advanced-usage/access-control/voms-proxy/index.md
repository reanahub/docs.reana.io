# VOMS-proxy

If your workflow needs special permissions that your Virtual Organization (VO) entitles you to, you can use VOMS  authentication. VOMS (Virtual Organization Membership Service) provides information on the user's relationship with their VO. VOs administer users and grant them permissions according to their group, role and capability. At CERN the different experiments such as ALICE, ATLAS, CMS and LHCb all have their own VO. Being part of a VO can give you access to globally distributed data analysis infrastructure.

If you do not already have a user certificate create one at [ca.cern.ch/ca](https://ca.cern.ch/ca/).

## Testing your credentials

Before moving to REANA, check that your credentials are in order.

```console
# Login to lxplus
$ ssh johndoe@lxplus.cern.ch

# Make sure userkey.pem is read/write only by the owner
$ ls -l ~/.globus
-rw-r--r--. usercert.pem
-r--------. userkey.pem

# Let us create a proxy certificate with the VO cms
$ voms-proxy-init --voms cms
Enter GRID pass phrase for this identity:

Contacting voms2.cern.ch:15002 [/DC=ch/DC=cern/OU=computers/CN=voms2.cern.ch] "cms"...
Remote VOMS server contacted succesfully.


Created proxy in /tmp/x509up_u131816.

Your proxy is valid until Wed Apr 01 00:43:08 CEST 2020
```

## Uploading secrets

To create the proxy certificate REANA needs access to your user certificate `usercert.pem`, encrypted private key `userkey.pem` and GRID pass phrase encoded in Base64. To encode your pass phrase exchange `mygridpassphrase` for your GRID pass phrase and perform:

```console
$ echo 'mygridpassphrase' | base64
bXlncmlkcGFzc3BocmFzZQo=
```

Upload these three secrets to REANA. In addition REANA needs information about your VO. This is communicated by the environment variable `VONAME` and can also be added to the secrets:

```console
$ reana-client secrets-add --file userkey.pem \
                           --file usercert.pem \
                           --env VOMSPROXY_PASS=bXlncmlkcGFzc3BocmFzZQo= \
                           --env VONAME=cms
```

## Setting voms-proxy requirement

Set `voms_proxy: true` for the steps that need a proxy certificate in the workflow specification.
Please note that step's docker image (e.g ``environment: 'reanahub/reana-auth-vomsproxy'``)
should have the VOMS client installed for the command `voms-proxy-info` to work.

Serial example:

```yaml hl_lines="9"
    workflow:
      type: serial
      specification:
        steps:
          - environment: 'reanahub/reana-auth-vomsproxy'
            voms_proxy: true
            commands:
            - voms-proxy-info
```
