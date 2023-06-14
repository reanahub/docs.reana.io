# Configuring cluster ingress

REANA manages external traffic to the cluster with the use of Kubernetes [Ingresses](https://kubernetes.io/docs/concepts/services-networking/ingress/).
The Helm chart automatically deploys Traefik as an [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) and creates the necessary Ingress resources.
If you would like to customise REANA's default behaviour by deploying your own Ingresses, this page provides several configuration hints and examples on how to achieve that.

## Configuring default Ingresses

REANA creates a single Ingress object by default, which can be customized with the following [Helm values](https://github.com/reanahub/reana/tree/master/helm/reana):

- `ingress.enabled` enables or disables the creation of Ingresses
- `ingress.annotations` is used to define which custom annotations should be applied to the Ingress resource
- `ingress.tls` can be used to configure a TLS certificate (see [Configuring TLS certificates](../configuring-tls-certificates/))

You can also specify additional Ingresses with the `ingress.extra` Helm value.
Each additional Ingress can be configured in the same way as the default one, with the addition of `ingress.extra[].name`.

As an example, this is how you would configure Traefik by creating two Ingresses, one to handle HTTPS traffic and the other to redirect HTTP requests to HTTPS:

```{ .yaml .copy-to-clipboard }
ingress:
  enabled: true
  tls:
    self_signed_cert: false
    secret_name: reana-tls-secret
    hosts:
      - reana.cern.ch
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/router.entrypoints: https
    traefik.ingress.kubernetes.io/router.tls: "true"
  extra:
    - name: http
      annotations:
        kubernetes.io/ingress.class: traefik
        traefik.ingress.kubernetes.io/router.entrypoints: http
        traefik.ingress.kubernetes.io/router.middlewares: kube-system-redirect-scheme@kubernetescrd
```

## Setting up manual Ingresses

If you would like to manually manage Ingresses, you should set `ingress.enabled` to false to disable the automatic creation of the Ingresses mentioned above.
You may also want to disable the internal Traefik instance by setting `traefik.enabled` to false.
Note that, when users open interactive sessions, REANA also creates dynamic Ingresses whose annotations can be customized with the `ingress.annotations` Helm value.

Your custom Ingress must redirect all the requests to `/api` and `/oauth` to the `<helm-release-prefix>-server` Service, while all the rest should be sent to `<helm-release-prefix>-ui`.
You can find an example of custom Ingress below.

```{ .yaml .copy-to-clipboard }
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: reana-ingress
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
spec:
  tls:
    - secretName: <tls-secret>
  rules:
    - http:
        paths:
        - path: /api
          pathType: Prefix
          backend:
            service:
              name: <helm-release-prefix>-server
              port:
                number: 80
        - path: /oauth
          pathType: Prefix
          backend:
            service:
              name: <helm-release-prefix>-server
              port:
                number: 80
        - path: /
          pathType: Prefix
          backend:
            service:
              name: <helm-release-prefix>-ui
              port:
                number: 80
      host: <hostname>
```

## Using reverse proxy

You may be interested in placing a (reverse) proxy service in front of REANA.
This requires additional configuration to make REANA work correctly.

Let us consider a setup in which HAProxy handles connections to REANA:

```text
          +-----------+    +---------+
Client -> |  HAProxy  | -> |  REANA  |
          +-----------+    +---------+
```

In this case, REANA has no way of knowing how the client connected to the server and which protocol the client used, since REANA will only see connections coming from the proxy.
If HAProxy also performs TLS termination, all the connections to REANA will be carried out over the HTTP protocol, even if the client connected over HTTPS.
This makes it impossible to construct correct absolute URLs on the server-side, since the traffic protocol is not known.

In these situations, you can make use of a non-standard `X-Forwarded-*` family of HTTP headers to preserve the details about the original connection.

!!! warning

    Using `X-Forwarded-*` headers can create security issues.
    You must make sure that the `X-Forwarded-*` headers provided by the client are either discarded or overwritten by a proxy you trust.
    See for example the [security concerns for X-Forwarded-For](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For#security_and_privacy_concerns).

You therefore need to configure HAProxy to set the `X-Forwarded-Proto` header for each incoming request:

```{ .text .copy-to-clipboard }
http-request set-header X-Forwarded-Proto https if { ssl_fc }
http-request set-header X-Forwarded-Proto http if !{ ssl_fc }
```

You then need to configure REANA's provided Traefik instance to trust the `X-Forwarded-*` headers coming from HAProxy, so that they won't be overwritten:

```{ .yaml .copy-to-clipboard }
traefik:
  additionalArguments:
    - "--entryPoints.web.forwardedHeaders.trustedIPs=127.0.0.1/32,192.168.1.7"
    - "--entryPoints.websecure.forwardedHeaders.trustedIPs=127.0.0.1/32,192.168.1.7"
```
