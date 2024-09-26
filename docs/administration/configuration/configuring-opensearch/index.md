# Configuring OpenSearch

OpenSearch with FluentBit is required for live job and workflow logs functionality. It is deployed using [OpenSearch Helm chart](https://github.com/opensearch-project/helm-charts) as REANA Helm chart dependency and should be enabled by changing `opensearch.enabled` value to `true`. Configuration can be passed to the chart by putting it under `opensearch` field in REANA Helm chart.

Example Helm command to add live logs to an existing REANA deployment (check [Authentication/authorization section](index.md#authenticationauthorization) on how to create password hashes):

```bash
helm upgrade reana reanahub/reana --wait \
  --set opensearch.customSecurityConfig.internalUsers.reana.hash='$So$mE$reAnAPaSswoRDhASh' \
  --set opensearch.customSecurityConfig.internalUsers.fluentbit.hash='$So$fLUenTmE$PaSswoRDhASh' \
  --set fluent-bit.outputConfig.httpPasswd='FluentBitUserPassword' \
  --set components.reana_workflow_controller.environment.REANA_OPENSEARCH_ENABLED=true \
  --set components.reana_workflow_controller.environment.REANA_OPENSEARCH_PASSWORD='ReanaUserPassword'
  --set opensearch.enabled=true \
  --set fluent-bit.enabled=true
```

[External OpenSearch service](index.md#external-opensearch-service) can be used instead (recommended).

## Number of instances

Only one OpenSearch instance is deployed by default. To add more instances, each of these instances needs to have its own `PersistentVolumeClaim` and `PersistentVolume` as each instance writes to a data directory with the same name but different contents - this will not work with `reana-shared-persistent-volume` or `reana-infrastructure-persistent-volume`. OpenSearch Helm chart uses `volumeClaimTemplates` to create a separate volume for each instance. It is possible to use `volumeClaimTemplates` with the `StorageClass` of choice (see [Multiple volumes with custom storage class](index.md#multiple-volumes-with-custom-storage-class)).

If you want to configure 3 OpenSearch instances instead of default 1 instance, change Helm values:

```yaml
opensearch:
  <...>
  singleNode: false
  replicas: 3
  <...>
```

OpenSearch allows deploying nodes of different types, e. g. `master` and `data`. Current REANA Helm setup does not allow it, and each node has all possible roles, see [default Helm chart roles value](https://github.com/opensearch-project/helm-charts/blob/4253842c1e4d3ac6d4aee294e905c1f20469adc2/charts/opensearch/values.yaml#L16-L20).

## Persistent storage

There are multiple ways to configure persistent strage for OpenSearch service.

### Host path

This is the simplest method, but not usable for production, see [Configuring storage volumes](../configuring-storage-volumes/index.md#hostpath).

OpenSearch for REANA is configured with `hostPath` by default, you should change it to one of the configurations below.

### Shared/infrastructure volume

To use shared or infrastructure volume, change `opensearch.extraVolumes` parameter in REANA `values.yaml` file:

```yaml
opensearch:
  <...>
  extraVolumes:
    - name: reana-opensearch-volume
      persistentVolumeClaim:
        claimName: reana-shared-persistent-volume  # or reana-infrastructure-persistent-volume
        readOnly: false
  <...>
```

Bear in mind that this only works with one OpenSearch node. To deploy multiple nodes, see [Multiple volumes with custom storage class](index.md#multiple-volumes-with-custom-storage-class).

### Multiple volumes with custom storage class

To deploy [multiple OpenSearch nodes](./index.md#number-of-instances), persistence configuration provided by OpenSearch chart should be used. It employs [`volumeClaimTemplates`](https://github.com/opensearch-project/helm-charts/blob/4253842c1e4d3ac6d4aee294e905c1f20469adc2/charts/opensearch/templates/statefulset.yaml#L27-L53) to create a separate `PersistentVolume` and `PersistentVolumeClaim` for each OpenSearch instance. You need to provide the name of your `StorageClass`, which you should have created as described in [NFS](../configuring-storage-volumes/index.md#nfs) or [CephFS](../configuring-storage-volumes/index.md#cephfs) configuration docs. The name of the `StorageClass` should be `reana-shared-volume-storage-class` or `reana-infrastructure-volume-storage-class`:

```yaml
opensearch:
  <...>
  persistence:
    enabled: true
    storageClass: "reana-shared-volume-storage-class"  # or reana-infrastructure-volume-storage-class
  <...>
  extraVolumes: []
  extraVolumeMounts: []
```

Additionally, you can configure persistence `size`, `annotations` and other attributes, see [docs](https://github.com/opensearch-project/helm-charts/tree/main/charts/opensearch).

Alternatively, `PersistentVolume` and `PersistentVolumeClaim` can be created for each node manually. `PersistentVolumeClaim` should be named as `<clusterName|nameOverride|fullnameOverride>-<nodeGroup>-<clusterName|nameOverride|fullnameOverride>-<nodeGroup>-<N>`, where `N` is a number of an OpenSearch node. The name of each node is either `clusterName-nodeGroup-X`, or `nameOverride-nodeGroup-X` if a `nameOverride` is specified, or `fullnameOverride-X` if a `fullnameOverride` is specified. By default it is `reana-opensearch-master-0`, `reana-opensearch-master-1`, etc., hence `PersistentVolumeClaim` names should be `reana-opensearch-master-reana-opensearch-master-0`, `reana-opensearch-master-reana-opensearch-master-1`, etc. `volumeClaimTemplates` will pick the existing volumes by their names and will not create new ones.

## TLS

OpenSearch uses TLS certificates for communication between nodes (not possible to turn off if using security features, even when only one OpenSearch node is deployed) and for REST API HTTPS (can be disabled). By default both internode communication and REST API use TLS. REST API HTTPS has to be enabled in order to use Basic Authentication for users as in this case username and password in plain text are sent to the server, hence without HTTPS TLS credentials risk being exposed. You can read more on TLS configuration in [OpenSearch documentation](https://opensearch.org/docs/latest/security/configuration/tls).

By default TLS certificates for OpenSearch nodes are generated automatically by a Helm function, similar to how it is done for [Ingress](../configuring-tls-certificates/index.md#default-self-signed-certificate). In production deployments, it is recommended to supply your own certificates by putting them in a secret and mounting to an OpenSearch pod (in `opensearch.secretMounts`).

!!! warning
    Add the subject to both CN and SANs of an OpenSearch certificate, otherwise `opensearch-py` client will be unable to verify the hostname.

When certificates change, OpenSearch has to be manually restarted or have dynamic certificate reload as described in the [documentation](https://opensearch.org/docs/latest/security/access-control/api/#reload-transport-certificates). If root CA has changed, services that connect to OpenSearch should also be restarted.

To use custom TLS certificates, change `opensearch.tls.generate` to `false` and manually create a secret with TLS certificates, which should have the following structure:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: reana-opensearch-tls-secrets
  namespace: <reana opensearch namespace>
type: kubernetes.io/tls
stringData:
  ca.crt: |
    <root CA public key>
  tls.crt: |
    <internode public key>
  tls.key: |
    <internode private key>
  admin.crt: |
    <admin public key>
  admin.key: |
    <admin private key>

```

Common name (CN) of each certificate is used in `opensearch.yml` configuration and by default should be `reana.io` (CA), `reana-opensearch-master.default.svc.cluster.local` (internode) and `opensearch-admin.reana.io` (admin). If you generate the certificates with different common names, you should change `opensearch.yml` values `plugins.security.nodes_dn` and `plugins.security.admin_dn` accordingly (via `opensearch.tls.cert.cn` and `opensearch.tls.admin.cn` Helm chart values).

Admin TLS certificates provide superadmin permissions and are stored in the same secret - there is no `admin` user, hence Basic Authentication credentials are not needed when making requests, only the TLS certificates need to be supplied. Helm generated admin certificates can be used while making REST API requests requiring superadmin permissions (e. g. TLS certificates reload), but not while executing `securityconfig.sh` script.

### Certificate renewal

Helm generated certificate validity in days can be configured via `opensearch.tls.ca.ttl`, `opensearch.tls.cert.ttl` and `opensearch.tls.admin.ttl`. At some point the certificates will have to be renewed whether they are Helm generated or custom.

Certificates can be updated on OpenSearch pod restart or using hot reload without OpenSearch pod restart.

OpenSearch restart takes up to several minutes, hence without hot reload there is a bigger chance of losing some job logs data. If you put REANA in maintenance mode and stopped all jobs, restart method is sufficient.

TLS certificate hot reload is enabled in the chart configuration and allows updating TLS certificates without restarting OpenSearch instance, see [OpenSearch docs](https://opensearch.org/docs/latest/security/configuration/tls/#hot-reloading-tls-certificates).

Certificate renewal steps:

1. Take note what certificates are currently used:

    ```bash
      kubectl exec statefulset/opensearch-cluster-master -- cat ./config/certs/tls.crt
    ```

1. Update the certificates. Either:

    - Delete the secret and upgrade Helm to generate new one:

      ```bash
      kubectl delete secret reana-opensearch-tls-secrets
      helm upgrade <...>
      ```

    - Or edit it by adding your new custom certificates:

      ```bash
      kubectl edit secret reana-opensearch-tls-secrets
      ```

1. Wait until new secret is mounted into the pods:

    ```bash
    sleep 60
    ```

1. Check that certificates have changed:

    ```bash
    kubectl exec statefulset/reana-opensearch-master -- cat ./config/certs/tls.crt
    ```

1. Load new OpenSearch certificates. Either:

    - Restart OpenSearch:

      ```bash
      kubectl rollout restart statefulset reana-opensearch-master
      ```

    - Hot reload certificates:

      ```bash
      kubectl port-forward service/reana-opensearch-master 9200:9200
      curl --cacert ca.crt --cert admin.crt --key admin.key \
        --insecure -XPUT https://localhost:9200/_plugins/_security/api/ssl/transport/reloadcerts
      curl --cacert ca.crt --cert admin.crt --key admin.key \
        --insecure -XPUT https://localhost:9200/_plugins/_security/api/ssl/http/reloadcerts
      ```

1. Restart related services if root CA has changed. There might be errors related to TLS until the services are restarted. You probably will lose some logs if there are running workflows or jobs as it can take up to several minutes to restart the services:

    ```bash
    kubectl rollout restart daemonset reana-fluent-bit
    kubectl rollout restart deployment reana-workflow-controller
    ```

## Authentication/authorization

REANA Helm chart configures system users using configuration files in OpenSearch `config/opensearch-security` folder. You can change security configuration by overriding `opensearch.customSecurityConfig` value which creates `internal_users.yaml`, `roles.yaml` and `roles_mapping.yaml` files. This configuration is loaded only once when OpenSearch is first deployed.

!!! warning
    Subsequent changes to OpenSearch security configuration files will not take effect unless you run `securityadmin.sh` script, which can also delete users that were created via REST API. Read the [documentation on Opensearch security configuration](https://opensearch.org/docs/latest/security/configuration/security-admin/) before attempting to make changes.
    To run `securityadmin.sh` script, you will need [custom admin certificates in PKCS#8 format](https://opensearch.org/docs/latest/security/configuration/generate-certificates/#generate-an-admin-certificate) - it will not work with Helm generated certificates.

By default two users are configured - `reana` and `fluentbit`. Their passwords need to be prepared by first spinning up OpenSearch instance in development environment, connecting to a pod and [running `plugins/opensearch-security/tools/hash.sh` script](https://opensearch.org/docs/latest/security/configuration/yaml/#internal_usersyml):

```bash
kubectl exec statefulset/opensearch-cluster-master -- ./plugins/opensearch-security/tools/hash.sh -p <somepassword>
```

The generated hashes for the passwords should be supplied to Helm with `--set opensearch.customSecurityConfig.internalUsers.reana.hash='$So$Me$pASsWOrD.HasH' --set opensearch.customSecurityConfig.internalUsers.fluentbit.hash='$So$Me$pASsWOrD.HasH'` options.

## External OpenSearch service

Using external OpenSearch service is recommended.

1. Create `reana` and `fluentbit` users in your OpenSearch service. Their passwords will have to be supplied to Helm via `components.reana_workflow_controller.environment.REANA_OPENSEARCH_PASSWORD` and `fluent-bit.outputConfig.httpPasswd` respectively.

1. Create `reana-opensearch-tls-secrets` as described in [TLS](index.md#tls) but only add `ca.crt` field that contains root CA of the OpenSearch certificates.

1. Run:

```bash
helm install reana reanahub/reana --wait \
  --set fluent-bit.outputConfig.httpPasswd='FluentBitUserPassword' \
  --set fluent-bit.enabled=true \
  --set components.reana_workflow_controller.environment.REANA_OPENSEARCH_ENABLED=true \
  --set components.reana_workflow_controller.environment.REANA_OPENSEARCH_PASSWORD='ReanaUserPassword' \
  --set components.reana_workflow_controller.environment.REANA_OPENSEARCH_HOST='your.opensearch.host'
```
