# Managing users

To manage users you will need an admin token and connection to the REANA-Server component:

```console
$ kubectl exec -i -t reana-server-aaaa-bbbb /bin/bash
root@reana-server-aaaa-bbbb:/code# read -s REANA_ADMIN_ACCESS_TOKEN
```

## Create users

```console
root@reana-server-aaaa-bbbb:/code# flask reana-admin user-create -e john.doe@cern.ch
User was successfully created.
ID                                     EMAIL                  ACCESS_TOKEN
aa37d63d-3186-45d5-aa40-5d221cb170bf   john.doe@example.org   xxxxxxxxxxxx
```

## List users

```console
root@reana-server-aaaa-bbbb:/code# flask reana-admin user-list
ID                                     EMAIL                      ACCESS_TOKEN                    ACCESS_TOKEN_STATUS
b5ff2c90-d2aa-4455-805d-599990043c39   john.doe@example.org       xxxxxxxxxxxx                    active
6d0a83d3-a5fb-415e-bc90-e2abed807ffe   new.web.user@example.org   None                            requested
```

## Export users

```console
root@reana-server-aaaa-bbbb:/code# flask reana-admin user-export > users.csv
```

## Import users

```console
root@reana-server-aaaa-bbbb:/code# flask reana-admin user-import --file users.csv
```

## Grant access tokens

```console
root@reana-server-aaaa-bbbb:/code# flask reana-admin token-grant -e new.web.user@example.org
Token for user aa37d63d-3186-45d5-aa40-5d221cb170bf (new.web.user@example.org) granted.

Token: c0fa47fa00ae4013a13fd7n
```

## Revoke access tokens

```console
root@reana-server-aaaa-bbbb:/code# flask reana-admin token-revoke -e new.web.user@example.org
User token c0fa47fa00ae4013a13fd7n (new.web.user@example.org) was successfully revoked.
```
