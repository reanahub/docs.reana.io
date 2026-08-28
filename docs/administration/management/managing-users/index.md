# Managing users

REANA user records are linked to an identity provider by the immutable issuer
and subject claims. Passwords, roles and bearer tokens remain owned by the OIDC
provider.

The commands below run `flask reana-admin` inside the REANA Server pod via
`kubectl exec`. Point `kubectl` at the right cluster first:

```{ .console .copy-to-clipboard }
$ export KUBECONFIG=~/mycluster/config
```

## Create or link users

Users are normally created automatically at their first permitted OIDC login.
An administrator can pre-create a local row when needed:

```console
$ kubectl exec deployment/reana-server -- flask reana-admin user-create \
    --email john.doe@example.org
```

Link a pre-existing row once the provider's immutable subject is known:

```console
$ kubectl exec deployment/reana-server -- flask reana-admin link-user-identity \
    --email john.doe@example.org \
    --idp-issuer https://identity.example.org/realms/reana \
    --idp-subject 01234567-89ab-cdef-0123-456789abcdef
```

Use `create-admin-user` with the same `--idp-issuer` and `--idp-subject`
options to create or link the platform administrator.

## List, export and import users

```console
$ kubectl exec deployment/reana-server -- flask reana-admin user-list
$ kubectl exec deployment/reana-server -- flask reana-admin user-export > myusers.csv
$ kubectl exec -i deployment/reana-server -- sh -c 'cat > /var/reana/myusers.csv' < myusers.csv
$ kubectl exec deployment/reana-server -- flask reana-admin user-import \
    --file /var/reana/myusers.csv
```

`user-export` writes `myusers.csv` on your own machine; `user-import` reads
its `--file` path from inside the pod, so the file needs to be copied there
first.

The list identifies linked users by `IDP_SUBJECT`; it does not expose an access
token.

## Revoke an identity

First remove the user's REANA role or entitlement at the identity provider.
Then revoke the REANA-side browser sessions, interactive sessions and GitLab
webhook authorization:

```console
$ kubectl exec deployment/reana-server -- flask reana-admin revoke-identity \
    --email john.doe@example.org
```

Use `--dry-run` to preview the action. Use `--delete-secret` only when the
installed GitLab webhook secret must be invalidated permanently.

REANA validates access tokens statelessly, so this command cannot invalidate an
already issued JWT. Such a token remains valid until its identity-provider
expiry; this is why removing the provider-side role is the first revocation
step.
