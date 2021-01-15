# Managing users

To manage users you will need to obtain administration credentials:

```console
$ export KUBECONFIG=~/mycluster/config
$ export REANA_ACCESS_TOKEN=$(kubectl get secret reana-admin-access-token -o json | jq -r '.data | map_values(@base64d) | .ADMIN_ACCESS_TOKEN')
```

## Create users

```console
$ kubectl exec -i -t deployment/reana-server -- flask reana-admin user-create --email john.doe@example.org --admin-access-token $REANA_ACCESS_TOKEN
User was successfully created.
ID                                     EMAIL                  ACCESS_TOKEN
aa37d63d-3186-45d5-aa40-5d221cb170bf   john.doe@example.org   xxxxxxxxxxxx
```

## List users

```console
$ kubectl exec -i -t deployment/reana-server -- flask reana-admin user-list --admin-access-token $REANA_ACCESS_TOKEN
ID                                     EMAIL                      ACCESS_TOKEN                    ACCESS_TOKEN_STATUS
b5ff2c90-d2aa-4455-805d-599990043c39   john.doe@example.org       xxxxxxxxxxxx                    active
6d0a83d3-a5fb-415e-bc90-e2abed807ffe   new.web.user@example.org   None                            requested
```

## Grant access tokens

```console
$ kubectl exec -i -t deployment/reana-server -- flask reana-admin token-grant --email new.web.user@example.org --admin-access-token $REANA_ACCESS_TOKEN
Token for user aa37d63d-3186-45d5-aa40-5d221cb170bf (new.web.user@example.org) granted.

Token: c0fa47fa00ae4013a13fd7n
```

## Revoke access tokens

```console
$ kubectl exec -i -t deployment/reana-server -- flask reana-admin token-revoke --email new.web.user@example.org --admin-access-token $REANA_ACCESS_TOKEN
User token c0fa47fa00ae4013a13fd7n (new.web.user@example.org) was successfully revoked.
```

## Export users

```console
$ kubectl exec -i -t deployment/reana-server -- flask reana-admin user-export --admin-access-token $REANA_ACCESS_TOKEN > myusers.csv
```

## Import users

```console
$ # put myusers.csv onto the node in the /var/reana directory and run:
$ kubectl exec -i -t deployment/reana-server -- flask reana-admin user-import --admin-access-token $REANA_ACCESS_TOKEN --file /var/reana/myusers.csv
```
