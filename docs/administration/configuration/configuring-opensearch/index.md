# Configuring OpenSearch

OpenSearch with FluentBit is required for live job and workflow logs functionality.
In general, connecting to an existing [external OpenSearch service](#external-opensearch-service) is recommended.

Nonetheless, REANA provides a way to deploy OpenSearch using the [OpenSearch Helm chart](https://github.com/opensearch-project/helm-charts) as a Helm chart dependency. See the related section on [Internal OpenSearch deployment](#internal-opensearch-deployment).

## External OpenSearch service

Using an external OpenSearch service is recommended.

1. Create the `reana` and `fluentbit` users in your OpenSearch instance. Their passwords will have to be supplied to Helm via `components.reana_workflow_controller.environment.REANA_OPENSEARCH_PASSWORD` and `fluent-bit.outputConfig.httpPasswd` respectively.

1. Create the `reana-opensearch-tls-secrets` secret as described in the [TLS](#tls) section, but only add the `ca.crt` field that contains the root CA of the OpenSearch certificates.

1. Configure REANA setting the following Helm values:

    - `fluent-bit.enabled` should be set to `true`
    - `fluent-bit.outputConfig.host` should be set to the hostname of the external OpenSearch instance
    - `fluent-bit.outputConfig.httpPasswd` should be set to the (plaintext) password of the `fluentbit` user
    - `components.reana_workflow_controller.environment.REANA_OPENSEARCH_ENABLED` should be set to `true`
    - `components.reana_workflow_controller.environment.REANA_OPENSEARCH_HOST` should be set to the hostname of the external OpenSearch instance
    - `components.reana_workflow_controller.environment.REANA_OPENSEARCH_PASSWORD` should be set to the (plaintext) password of the `reana` user

1. Deploy or upgrade REANA

## Internal OpenSearch deployment

Even though not recommended, OpenSearch can also be deployed via the REANA Helm Chart.
It is normally configured to have two users, `reana` and `fluentibit`, used by the respective services to access OpenSearch.

For a standard REANA deployment, theseare the Helm values you need to configure:

- `opensearch.enabled` should be set to `true`, to enable the deployment of OpenSearch
- `opensearch.customSecurityConfig.internalUsers.reana.hash` should be set to the hash of the `reana` user's password
- `opensearch.customSecurityConfig.internalUsers.fluentbit.hash` should be set to the hash of the `fluentbit` user's password
- `fluent-bit.enabled` should be set to `true`
- `fluent-bit.outputConfig.httpPasswd` should be set to the (plaintext) password of the `fluentbit` user
- `components.reana_workflow_controller.environment.REANA_OPENSEARCH_ENABLED` should be set to `true`
- `components.reana_workflow_controller.environment.REANA_OPENSEARCH_PASSWORD` should be set to the (plaintext) password of the `reana` user

Check the [Authentication/authorization section](#authenticationauthorization) for instructions on how to create password hashes in the format needed by OpenSearch.

Additional configuration can be passed to the subchart via the `opensearch` field in the REANA Helm chart values.

!!!warning
    Due to some limitations of Helm subcharts, if the Helm release name you have chosen when deploying REANA is different from the default `reana`, then you will also have to customise the following Helm values:

    - `components.reana_workflow_controller.environment.REANA_OPENSEARCH_HOST`: `<release>-opensearch-master`
    - `opensearch.clusterName`: `<release>-opensearch`
    - `opensearch.masterService`: `<release>-opensearch-master`
    - `opensearch.tls.cert.cn`: `<release>-opensearch-master`
    - `opensearch.config.opensearch.yml` (if modified): `cluster.name: <release>-opensearch`
    - `opensearch.secretMounts[0].secretName`: `<release>-opensearch-tls-secrets`
    - `opensearch.securityConfig.internalUsersSecret`: `<release>-opensearch-config-secrets`
    - `opensearch.securityConfig.rolesSecret`: `<release>-opensearch-config-secrets`
    - `opensearch.securityConfig.rolesMappingSecret`: `<release>-opensearch-config-secrets`
    - `opensearch.extraEnvs[name==OPENSEARCH_INITIAL_ADMIN_PASSWORD].valueFrom.secretKeyRef.name`: `<release>-opensearch-secrets`
    - `fluent-bit.outputConfig.host`: `<release>-opensearch-master`
    - `fluent-bit.extraVolumes[0].secret.secretName`: `<release>-opensearch-tls-secrets`
    - `fluent-bit.priorityClassName`: `<release>-fluent-bit-priority-class`

### Number of instances

Only one OpenSearch instance is deployed by default. If you want to deploy multiple instances, then each of them needs to have its own `PersistentVolumeClaim` and `PersistentVolume` to avoid conflicts, as each instance will write to the same location on disk. The OpenSearch Helm chart uses `volumeClaimTemplates` to create a separate volume for each instance, see the related [Multiple volumes with custom storage class](#multiple-volumes-with-custom-storage-class) section.

As an example, this is how you would configure the deployment to have three OpenSearch instances via Helm values:

```yaml
opensearch:
  singleNode: false
  replicas: 3
```

Even though OpenSearch allows deploying nodes of different types, e.g. `master` nodes and `data` nodes, the REANA Helm chart does not support it. This means that each node has all possible roles, see the [default roles](https://github.com/opensearch-project/helm-charts/blob/4253842c1e4d3ac6d4aee294e905c1f20469adc2/charts/opensearch/values.yaml#L16-L20) in the OpenSearch Helm Chart.

### Persistent storage

There are multiple ways to configure persistent strage for OpenSearch.

#### Host path

This is the simplest method but not usable for production, also due to security risks.

In any case, OpenSearch for REANA is configured with `hostPath` by default, but you should customise your deployment to use one of the other storage alternatives.

#### REANA shared or infrastructure volume

To use the shared or infrastructure volume also for OpenSearch, you should change the `opensearch.extraVolumes` Helm value, like so:

```yaml
opensearch:
  extraVolumes:
    - name: reana-opensearch-volume
      persistentVolumeClaim:
        claimName: reana-shared-persistent-volume # or reana-infrastructure-persistent-volume
        readOnly: false
```

Bear in mind that this only works when deploying OpenSearch in single node mode. To deploy multiple nodes, see [Multiple volumes with custom storage class](#multiple-volumes-with-custom-storage-class).

#### Multiple volumes with custom storage class

To deploy [multiple OpenSearch nodes](./#number-of-instances), persistent storage should be configured directly via the OpenSearch Helm Chart.

In particular, [`volumeClaimTemplates`](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#volume-claim-templates) is used to create a separate `PersistentVolume` and `PersistentVolumeClaim` for each OpenSearch instance deployed.
To do so, you need to provide the name of your chosen `StorageClass`, for example:

```yaml
opensearch:
  persistence:
    enabled: true
    storageClass: "<your-storage-class>"
  extraVolumes: []
  extraVolumeMounts: []
```

Note that you can further customise OpenSearch's persistent volumes, for example by specifying the `size`, `labels` and `annotations`. For more details, see the [values of the OpenSearch Helm Chart](https://github.com/opensearch-project/helm-charts/blob/e43cf7dea1c01570971c70ff7d120b165bcfc28e/charts/opensearch/values.yaml#L197-L221).

Alternatively, `PersistentVolumeClaim`s can be created for each node manually, but their names should be the same that would be generated by `volumeClaimTemplates`. In this way, `volumeClaimTemplates` will pick the existing volumes by their names and will not create new ones.
in particular each claim should be named as `<clusterName|nameOverride|fullnameOverride>-<nodeGroup>-<clusterName|nameOverride|fullnameOverride>-<nodeGroup>-<N>`, where `N` is the number of an OpenSearch node.

As an example, by default: nodes are named `reana-opensearch-master-0`, `reana-opensearch-master-1`, etc., thus `PersistentVolumeClaim` names should be `reana-opensearch-master-reana-opensearch-master-0`, `reana-opensearch-master-reana-opensearch-master-1`, and so on.

## TLS

OpenSearch uses TLS certificates for secure communication between nodes, and this feature cannot be turned off, even in single node mode.
TLS certificates are also used to secure the REST API with HTTPS, but this can be disabled if wanted.

Note however that HTTPS has to be enabled in order to use Basic Authentication, as otherwise usernames and passwords would be sent in plain text to the server, with the risk of being exposed. You can read more on TLS configuration in [OpenSearch documentation](https://opensearch.org/docs/latest/security/configuration/tls).

By default TLS certificates for OpenSearch nodes are generated automatically by a Helm function, similar to how it is done for [Ingress](../configuring-tls-certificates/#default-self-signed-certificate). In production deployments, it is recommended to supply your own certificates by storing them in a Kubernetes secret, which is then mounted inside the OpenSearch pods.

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

!!! warning
    Add the subject to both CN and SANs of an OpenSearch certificate, otherwise `opensearch-py` client will be unable to verify the hostname.

The Common Name (CN) of each certificate is used in `opensearch.yml` configuration and by default should be `reana.io` (CA), `reana-opensearch-master` (internode) and `opensearch-admin.reana.io` (admin). If you generate the certificates with different common names, you should change the `opensearch.yml` values `plugins.security.nodes_dn` and `plugins.security.admin_dn` accordingly (via `opensearch.tls.cert.cn` and `opensearch.tls.admin.cn` Helm chart values).

When certificates change, OpenSearch has to be manually restarted. In alternative, you can set up dynamic certificate reload as described in the [official documentation](https://opensearch.org/docs/latest/security/access-control/api/#reload-transport-certificates). If the root CA has changed, services that connect to OpenSearch should also be restarted.

Admin TLS certificates provide superadmin permissions and are stored in the same secret. This means that there is no `admin` user: Basic Authentication credentials are not needed when making requests, only the TLS certificates need to be supplied. Helm-generated admin certificates can be used while making REST API requests requiring superadmin permissions, for example reloading TLS certificates, but not while executing `securityconfig.sh` script.

### Certificate renewal

The duration of Helm-generated certificate can be configured via `opensearch.tls.ca.ttl`, `opensearch.tls.cert.ttl` and `opensearch.tls.admin.ttl` by providing the desired number of days.

Certificates can be updated by restarting OpenSearch's pod restart or by hot-reloading OpenSearch without restarting it.

Restarting OpenSearch takes up to several minutes, hence without hot-reload some job logs might be lost. If you are sure that no job will be running, for example by putting REANA in maintenance mode, then restarting OpenSearch can be sufficient.

TLS certificate hot-reload is enabled in the Helm chart configuration and allows updating TLS certificates without restarting OpenSearch instance, see [OpenSearch docs](https://opensearch.org/docs/latest/security/configuration/tls/#hot-reloading-tls-certificates).

Certificate renewal steps:

1. Take note of which certificates are currently being used.

    ```bash
      kubectl exec statefulset/opensearch-cluster-master -- cat ./config/certs/tls.crt
    ```

1. Update the certificates.

    1. If certificates are auto-generated by Helm, then delete the secret and simply perform an upgrade of your REANA instance using Helm:

        ```bash
        kubectl delete secret reana-opensearch-tls-secrets
        helm upgrade <...>
        ```

    1. Otherwise, edit or re-create the Kubernetes secret, adding your new certificates:

        ```bash
        kubectl edit secret reana-opensearch-tls-secrets
        ```

1. Wait until the new certificates are mounted into the pods.

1. Check that certificates have changed.

    ```bash
    kubectl exec statefulset/reana-opensearch-master -- cat ./config/certs/tls.crt
    ```

1. Load new OpenSearch certificates.

    1. If hot-reloading the certificates:

        ```bash
        kubectl port-forward service/reana-opensearch-master 9200:9200
        curl --cacert ca.crt --cert admin.crt --key admin.key \
          --insecure -XPUT https://localhost:9200/_plugins/_security/api/ssl/transport/reloadcerts
        curl --cacert ca.crt --cert admin.crt --key admin.key \
          --insecure -XPUT https://localhost:9200/_plugins/_security/api/ssl/http/reloadcerts
        ```

    1. Otherwise, restart OpenSearch:

        ```bash
        kubectl rollout restart statefulset reana-opensearch-master
        ```

1. If the root CA certifcate has changed, you might see errors in the logs related to TLS and you should restart all the related services. You might lose some logs if there are running workflows or jobs as it can take up to several minutes to restart the services.

    ```bash
    kubectl rollout restart daemonset reana-fluent-bit
    kubectl rollout restart deployment reana-workflow-controller
    ```

## Authentication/authorization

REANA's Helm chart configures system users using configuration files in OpenSearch's `config/opensearch-security` folder. You can change these settings by overriding the `opensearch.customSecurityConfig` Helm value, which creates the `internal_users.yaml`, `roles.yaml`, and `roles_mapping.yaml` files. Note that this configuration is loaded only once when OpenSearch is first deployed.

!!! warning
    Subsequent changes to OpenSearch security configuration files will not take effect unless you run `securityadmin.sh` script, which can also delete users that were created via REST API. Read the [documentation on Opensearch security configuration](https://opensearch.org/docs/latest/security/configuration/security-admin/) before attempting to make changes.
    To run `securityadmin.sh` script, you will need [custom admin certificates in PKCS#8 format](https://opensearch.org/docs/latest/security/configuration/generate-certificates/#generate-an-admin-certificate) - it will not work with Helm generated certificates.

By default two users are configured: `reana` and `fluentbit`. Their password hashes need to be prepared by first spinning up an OpenSearch instance in a development environment, connecting to a pod and running the `plugins/opensearch-security/tools/hash.sh` script:

```bash
kubectl exec statefulset/opensearch-cluster-master -- ./plugins/opensearch-security/tools/hash.sh -p <somepassword>
```

The generated password hashes will then need to be supplied to Helm via the `opensearch.customSecurityConfig.internalUsers.reana.hash` and `opensearch.customSecurityConfig.internalUsers.fluentbit.hash` Helm values.

For more details regarding OpenSearch users, please take a look at the [`internal_users.yml` official docs](https://opensearch.org/docs/latest/security/configuration/yaml/#internal_usersyml).