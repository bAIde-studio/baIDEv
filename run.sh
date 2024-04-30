#!/bin/bash

# Setup PATH
export PATH="/usr/lib/jvm/java-18-openjdk/bin:bin/:$PATH"

# Run penpot exporter
PENPOT_TENANT=pro \
PENPOT_PUBLIC_URI=redacted \
PENPOT_REDIS_URI=redacted \
penpot-exporter&

# Run penpot backend
PENPOT_TENANT=pro \
PENPOT_PUBLIC_URI=redacted \
PENPOT_HTTP_SERVER_HOST=redacted \
PENPOT_HTTP_SERVER_PORT=6060 \
PENPOT_SREPL_HOST=redacted \
PENPOT_SREPL_PORT=6062 \
PENPOT_DATABASE_URI=redacted \
PENPOT_DATABASE_USERNAME=redacted \
PENPOT_DATABASE_PASSWORD=redacted \
PENPOT_REDIS_URI=redacted \
PENPOT_ASSETS_STORAGE_BACKEND=redacted \
PENPOT_STORAGE_ASSETS_FS_DIRECTORY=redacted \
PENPOT_TMP_DIRECTORY=redacted \
PENPOT_SECRET_KEY=redacted \
PENPOT_TELEMETRY_ENABLED=false \
PENPOT_SMTP_ENABLED=true \
PENPOT_SMTP_DEFAULT_FROM=redacted \
PENPOT_SMTP_DEFAULT_REPLY_TO=redacted \
PENPOT_SMTP_HOST=redacted \
PENPOT_SMTP_PORT=redacted \
PENPOT_SMTP_USERNAME=redacted \
PENPOT_SMTP_PASSWORD=redacted \
PENPOT_SMTP_TLS=true \
PENPOT_SMTP_SSL=false \
PENPOT_LDAP_HOST=redacted \
PENPOT_LDAP_PORT=redacted \
PENPOT_LDAP_SSL=redacted \
PENPOT_LDAP_STARTTLS=redacted \
PENPOT_LDAP_BASE_DN=redacted \
PENPOT_LDAP_BIND_DN=redacted \
PENPOT_LDAP_BIND_PASSWORD=redacted \
PENPOT_LDAP_ATTRS_USERNAME=redacted \
PENPOT_LDAP_ATTRS_EMAIL=redacted \
PENPOT_LDAP_ATTRS_FULLNAME=redacted \
PENPOT_LDAP_ATTRS_PHOTO=redacted \
PENPOT_LOGIN_WITH_LDAP=true \
PENPOT_FLAGS="enable-backend-asserts enable-audit-log enable-transit-readable-response enable-login-with-ldap disable-login disable-registration disable-demo-users" \
java -Djava.io.tmpdir="redacted" -jar penpot.jar -m app.main