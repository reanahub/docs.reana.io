# Configuring TLS certificates

## Default self-signed certificate

A self-signed certificate is automatically generated each time REANA's Helm
chart is deployed or upgraded. This certificate is valid for 90 days and is
stored in a Kubernetes secret named `<helm-release-prefix>-tls-secret`. To
generate a new TLS certificate, you can simply perform an upgrade of your REANA
instance using `helm upgrade`.

You can disable the generation of the self-signed certificate by setting the
`ingress.tls.self_signed_cert` Helm value to `false` whilst deploying your REANA
instance. If you want to use longer lasting certificates, see the
[Using a custom certificate](#using-a-custom-certificate) section.

The self-signed TLS certificate is used in the REANA web interface. The web site
will appear as insecure to the users due to the certificate being self-signed.
This may be acceptable on development instances with limited user exposure.
However, for production deployments, please use a real TLS certificate using
certificate authorities such as [Let's Encrypt](https://letsencrypt.org/).

## Using a custom certificate

If you have a custom certificate issued by a trusted Certificate Authority (CA),
you can configure REANA to use it as follows.

First, prepare the `mycert.crt` and `mycert.key` files which contain
respectively the public and private part of your certificate.

!!! note

    You can use this same technique with a custom self-signed certificate.
    For example, to create a self-signed certificate lasting 365 days, you can
    generate `mycert.crt` and `mycern.key` as follows:

    ```{ .console .copy-to-clipboard }
    $ # source https://letsencrypt.org/docs/certificates-for-localhost/
    $ openssl req -x509 -out mycert.crt -keyout mycert.key \
      -newkey rsa:2048 -nodes -sha256 -days 365 \
      -subj '/CN=localhost' -extensions EXT -config <( \
       printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
    ```

Using `mycert.crt` and `mycert.key`, you should then create a
[Kubernetes TLS secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets)
containing the certificate, which in this example will be called
`reana-mycert-secret`:

```{ .console .copy-to-clipboard }
$ kubectl create secret tls reana-mycert-secret --cert=./cert.crt --key=./cert.key
```

Finally, you must set the necessary Helm values whilst deploying REANA:

- `ingress.tls.self_signed_cert` should be set to `false`, so that the default
  self-signed certificate is not generated;
- `ingress.tls.secret_name` should be set to the name of the Kubernetes secret
  containing the certificate, in this case `reana-mycert-secret`.

## Automatic certificate issuance

You may also be able to let Kubernetes handle the issuance and configuration of
TLS certificates so that the process would be fully automatic. Different ingress
controllers may require different configurations, but the setup usually requires
to annotate REANA's `Ingress` object.

For example, in order to use the Let's Encrypt certificate service with the
Traefik ingress controller, it would be necessary to discover and edit the
ingress `ConfigMap`:

```console
$ # discover ingress config map
$ kubectl get configmaps --all-namespaces | grep ingress
$ # edit config map to input the acme section as listed below
$ kubectl edit configmaps -n kube-system ingress-traefik
$ # delete ingress pod to trigger certificate issuance
$ kubectl -n kube-system delete $(kubectl -n kube-system get pod -o name | grep traefik)
```

The newly added `acme` section should be similar to this:

```toml
    [acme]
      email = "john.doe@example.org"
      storage = "acme.json"
      entryPoint = "https"
      ACMELogging = true
    [acme.tlsChallenge]
    [[acme.domains]]
      main = "reana.example.org"
```
