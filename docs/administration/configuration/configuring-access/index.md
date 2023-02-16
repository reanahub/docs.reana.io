# Configuring user access

## User registration via sign up form

By exposing the REANA User Interface, the default configuration allows
users to sign-up.

When accessing the UI for the first time, users will be prompted with a
sign-in form and a link to the sign-up form:

![ui-sign-in](../../../images/ui-sign-in.png)

After signing up, an email is sent to the user's email address for
confirmation. Once the email address is confirmed, the user can then ask
administrators for an access token.

If you would like to disable the email verification step, you can add
`REANA_USER_EMAIL_CONFIRMATION: false` Helm value to [`components.reana_server.environment`](https://github.com/reanahub/reana/tree/master/helm/reana).

If you would like to disable the sign-up form completely, and [add your
users manually](../../management/managing-users), you can configure
[`components.reana_ui.hide_signup`](https://github.com/reanahub/reana/tree/master/helm/reana)
Helm value accordingly.

## User registration via Single Sign-On

Handling of users with Single Sign-On (SSO) is also possible. Currently SSO is supported for CERN as well as any third-party SSO provider, which supports [Keycloak](https://www.keycloak.org/).

### Keycloak Single Sign-On Configuration

Third-party SSO providers can be configured by adding an item with the respective configuration to the [`login`](https://github.com/reanahub/reana/tree/master/helm/reana) list in the Helm values:

```yaml
login:
  - name: your-provider
    type: keycloak
    config:
      title: "YOUR PROVIDER"
      base_url: "https://your-host.com"
      realm_url: "https://your-host.com/auth/realms/your-realm"
      auth_url: "https://your-host.com/auth/realms/your-realm/protocol/openid-connect/auth"
      token_url: "https://your-host.com/auth/realms/your-realm/protocol/openid-connect/token"
      userinfo_url: "https://your-host.com/auth/realms/your-realm/protocol/openid-connect/userinfo"
```

**Please note that currently only one provider of the type `keycloak` is supported.**

Further the respective client key and secret need to be specified under the [`secrets.login`](https://github.com/reanahub/reana/tree/master/helm/reana) Helm value:

```yaml
secrets:
  login:
    your-provider:
      consumer_key: your-client-key
      consumer_secret: your-client-secret
```

**This method should not be used in production, instead, secrets should be managed outside of the Helm values file.**

When accessing the UI you will see a page like this:

![ui-sso-keycloak](../../../images/ui-sso-keycloak.png)

For further information on how to use Keycloak, see [Keycloak’s own documentation](https://www.keycloak.org/docs/latest/server_admin/index.html#_oidc_clients).

### CERN Single Sign-On Configuration

Single Sign-On is available for CERN deployments via [`components.reana_ui.cern_sso`](https://github.com/reanahub/reana/tree/master/helm/reana)
Helm value. This configuration can be combined with local users or used
exclusively. When accessing the UI you will see a page like this:

![ui-sso](../../../images/ui-sso.png)

When clicking on "Sign in with SSO" the users will be redirected to the
corresponding login page to enter their SSO provider credentials. Once
authenticated, they will be redirected back to REANA with their user
logged in.

You might also want to disable the local users functionality altogether
to rely only on SSO users. To do this, set [`components.reana_ui.local_users`](https://github.com/reanahub/reana/tree/master/helm/reana)
Helm value to `false`.
