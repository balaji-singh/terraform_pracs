#!/bin/bash

# Set variables for the on-premises and cloud-based OpenLDAP servers
ONPREM_LDAP_HOST=ldap://onprem.example.com
ONPREM_LDAP_BINDDN="cn=admin,dc=example,dc=com"
ONPREM_LDAP_BINDPW=secret
CLOUD_LDAP_HOST=ldap://cloud.example.com
CLOUD_LDAP_BINDDN="cn=admin,dc=example,dc=com"
CLOUD_LDAP_BINDPW=secret

# Enable the syncprov overlay on the on-premises OpenLDAP server
ldapmodify -H "$ONPREM_LDAP_HOST" -D "$ONPREM_LDAP_BINDDN" -w "$ONPREM_LDAP_BINDPW" <<EOF
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: syncprov.la
EOF

# Configure the syncprov overlay on the on-premises OpenLDAP server
ldapmodify -H "$ONPREM_LDAP_HOST" -D "$ONPREM_LDAP_BINDDN" -w "$ONPREM_LDAP_BINDPW" <<EOF
dn: olcOverlay=syncprov,olcDatabase={1}hdb,cn=config
changetype: add
objectClass: olcOverlayConfig
objectClass: olcSyncProvConfig
olcOverlay: syncprov
olcSpNoPresent: TRUE
olcSpReloadHint: TRUE
EOF

# Set up a syncprov consumer on the cloud-based OpenLDAP server
ldapmodify -H "$CLOUD_LDAP_HOST" -D "$CLOUD_LDAP_BINDDN" -w "$CLOUD_LDAP_BINDPW" <<EOF
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: syncprov.la
EOF

ldapmodify -H "$CLOUD_LDAP_HOST" -D "$CLOUD_LDAP_BINDDN" -w "$CLOUD_LDAP_BINDPW" <<EOF
dn: olcDatabase={1}hdb,cn=config
changetype: modify
add: olcSyncRepl
olcSyncRepl: rid=001 provider=ldap://onprem.example.com bindmethod=simple binddn="cn=admin,dc=example,dc=com" credentials=secret searchbase="dc=example,dc=com" logbase="cn=accesslog" logfilter="(&(objectClass=auditWriteObject)(reqResult=0))" schemachecking=on type=refreshAndPersist retry="60 +" syncdata=accesslog
EOF

# Restart the OpenLDAP servers to apply
