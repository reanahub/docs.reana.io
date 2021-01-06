# Configuring user access

The default REANA configuration allows users to sign up, after which
an email is sent to the user's email address for confirmation.  Once
the email address is confirmed, the user can then ask administrators
for an access token.

If you would like to disable the email verification step, you can add
`REANA_USER_EMAIL_CONFIRMATION: false` Helm value to [`components.reana_server.environment`](https://github.com/reanahub/reana/tree/master/helm/reana).

If you would like to disable the sign-up form completely, and add your
users manually, you can configure
[`components.reana_ui.hide_signup`](https://github.com/reanahub/reana/tree/master/helm/reana)
Helm value accordingly.

Note that it is also possible to deploy a Single-Sign On system for
managing user access. Currently, this is only available for CERN
deployments.
