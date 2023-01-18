# Configuring Ingress Controller

By default, REANA uses `traefik` as an ingress controller. However, it is possible to replace the `traefik` ingress with an `nginx` ingress.

Currently, this change is only possible manually, as it is not yet fully supported by the REANA helm chart.

The following code snipped shows a possible `nginx` ingress manifest:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/ssl-redirect: "true"
    kubernetes.io/ingress.class: nginx
  name: <helm-release-name>-ingress
  namespace: <reana-namespace>
spec:
  rules:
  - http:
      paths:
      - backend:
          service:
            name: <helm-release-name>-server
            port:
              number: 80
        path: /api
        pathType: Prefix
      - backend:
          service:
            name: <helm-release-name>-server
            port:
              number: 80
        path: /oauth
        pathType: Prefix
      - backend:
          service:
            name: <helm-release-name>-ui
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - secretName: <helm-release-name>-tls-secret
status:
  loadBalancer:
    ingress:
    - ip: <lb-ip>
```

which can be deployed manually via: `kubectl apply -f <ingress-yaml-filename>.yaml`.