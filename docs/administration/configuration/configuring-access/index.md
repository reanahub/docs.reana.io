# Configuring user access

REANA authenticates users with OpenID Connect (OIDC). The identity provider
owns passwords, access-token issuance and user entitlements; REANA validates
the provider's signed JWT access tokens and creates the corresponding local
user record on first login.

JWT validation happens at the `reana-server` API boundary only, not
independently in every internal service -- those trust `reana-server`
because they are not reachable from outside the cluster. The browser does
not hold a JWT itself: it authenticates through the BFF, an HTTP-only REANA
session backed by OIDC refresh credentials, described below. REANA also does
not yet have a groups or role-based authorization model beyond the single
`requiredRole` gate configured below -- access is granted per user, not per
group.

## Configure an external OIDC provider

Register two clients at the provider:

- a public client for `reana-client`, with Authorization Code and device
  authorization enabled. Browser-based CLI login uses Authorization Code with
  PKCE and a loopback redirect URI; and
- a confidential web client for the browser login, with the callback URL
  `https://reana.example.org/api/oauth/callback`.

Configure the provider and the accepted access-token audience in Helm values:

```{ .yaml .copy-to-clipboard }
keycloak:
  enabled: false

auth:
  issuer: https://identity.example.org/realms/reana
  audience: reana-cli,reana-server
  clientId: reana-cli
  webClientId: reana-server
  rolesClaim: reana_roles
  requiredRole: "reana:user"
  bffEnabled: true

secrets:
  auth:
    REANA_AUTH_WEB_CLIENT_SECRET: replace-me
```

REANA normally discovers the authorization, token, UserInfo and JWKS endpoints
from the issuer's OpenID configuration. The `auth.*Url` values can override
individual endpoints when discovery is not suitable. Production issuers must
use HTTPS; use `auth.caBundle` for a private certificate authority.

REANA caches both the discovery document and the JWKS signing keys
in-process, refreshing on a fixed TTL. If a refresh fails while the issuer is
briefly unreachable, the previous, still-cached copy keeps being served for a
bounded grace period rather than failing every request outright -- and,
symmetrically, a signing key removed from a *reachable* issuer (e.g. because
it was compromised) stops being trusted once that grace period elapses, even
though token expiry alone would not otherwise bound it: whoever holds the
removed key's private half can still mint tokens with any `exp` they like.
Tune or disable this fallback on `reana-server`:

```{ .yaml .copy-to-clipboard }
components:
  reana_server:
    environment:
      REANA_AUTH_JWKS_STALE_GRACE: 3600      # seconds, default; 0 disables it
      REANA_AUTH_DISCOVERY_STALE_GRACE: 3600 # seconds, default; 0 disables it
```

The configured `audience` is mandatory and may contain a comma-separated list
when the public and web clients receive differently audienced tokens. The
configured `rolesClaim` must be a top-level array in the access token, and
`requiredRole` must match one of its values. Removing that role at the identity
provider prevents newly issued tokens from accessing REANA.

## Browser and command-line login

The browser uses an HTTP-only REANA session backed by OIDC refresh credentials.
The command-line client authenticates with a local browser-based login by
default and stores its credentials locally; pass `--headless` to use the
device flow instead on machines without a browser (e.g. over SSH):

```{ .console .copy-to-clipboard }
$ export REANA_SERVER_URL=https://reana.example.org
$ reana-client login
$ reana-client ping
$ reana-client logout
```

Do not provision or distribute REANA-owned bearer tokens. Administrators can
pre-create or explicitly link local user rows with the `flask reana-admin`
commands described in [Managing users](../../management/managing-users/).

## Link accounts when upgrading

Accounts created before OIDC authentication do not have an immutable issuer
and subject attached. Link them explicitly before their owners sign in:

```{ .console .copy-to-clipboard }
$ kubectl exec deployment/reana-server -- flask reana-admin link-user-identity \
    --email jane.doe@example.org \
    --idp-issuer https://identity.example.org/realms/reana \
    --idp-subject 01234567-89ab-cdef-0123-456789abcdef
```

For a controlled institutional issuer, matching existing accounts can instead
be linked automatically by verified email. Configure the narrowest applicable
issuer and domain allowlists on REANA Server:

```{ .yaml .copy-to-clipboard }
components:
  reana_server:
    environment:
      REANA_AUTH_EMAIL_LINKING_ENABLED: "true"
      REANA_AUTH_EMAIL_LINKING_ISSUER_ALLOWLIST: https://identity.example.org/realms/reana
      REANA_AUTH_EMAIL_LINKING_DOMAIN_ALLOWLIST: example.org
```

Some institutional issuers omit the standard `email_verified` claim while
verifying addresses out-of-band. Only for such an issuer, add its exact URL to
`REANA_AUTH_EMAIL_LINKING_ASSUME_VERIFIED_ISSUERS`. This is an administrator
attestation for an *absent* claim: a present value must be the boolean `true`;
`false`, `null`, strings and numbers are never accepted for account linking.
Automatic linking is one-shot and will not move an already-linked account to a
different identity.

The browser-based login binds a temporary local callback server on an
OS-assigned, ephemeral port, following RFC 8252's guidance for native
apps; a well-behaved identity provider is expected to match the redirect
URI on scheme and host only, not on the exact port. Not every provider
supports that, though. If yours requires an exact-match redirect URI
registration, set `REANA_CLIENT_LOGIN_LOOPBACK_PORT` on the machine
running `reana-client` to pin one fixed port, and register
`http://127.0.0.1:<port>/callback` with the provider once. The trade-off:
login then fails outright if something else on that machine is already
using the port, instead of the ephemeral default always finding a free
one.

## Bundled Keycloak

The chart's bundled Keycloak is intended for development and small test
deployments.

For local development against a `reana` chart checkout (e.g. a `kind`
cluster), the development values profile enables it with deliberately
non-production credentials:

```{ .console .copy-to-clipboard }
$ helm upgrade --install reana ./helm/reana \
    --values helm/configurations/values-dev.yaml
```

This profile is tailored to that local setup specifically (a `localhost`
frontend URL, a plaintext Keycloak backchannel, `:latest`-tagged images) and
requires the `reana` chart repository checked out locally for the relative
`--values` path to resolve -- it is not meant as a general-purpose small
deployment starting point.

For a small test deployment that only needs the published chart (no local
checkout), the essential values are:

```{ .yaml .copy-to-clipboard }
keycloak:
  enabled: true
  frontend_url: https://reana.example.org/keycloak
  admin_user: reana-keycloak-admin
  admin_password: replace-with-a-strong-secret
  database:
    mode: bundled

secrets:
  auth:
    REANA_AUTH_WEB_CLIENT_SECRET: replace-with-a-strong-secret
  keycloak:
    database_password: replace-with-a-strong-secret
```

`database.mode: bundled` creates a separate Keycloak database and role in the
chart-managed PostgreSQL service. Use `external` with a pre-provisioned
PostgreSQL service for independently operated storage. The explicit
`ephemeral` mode is development-only and loses users, sessions and signing keys
when its pod is replaced. Production installations should use a separately
operated identity provider rather than the bundled development service.
