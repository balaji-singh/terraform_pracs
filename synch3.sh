#!/bin/bash

# Set variables for the on-premises and cloud-based OpenLDAP servers
ON_PREM_LDAP_SERVER="ldap://on-premises.example.com"
CLOUD_LDAP_SERVER="ldap://cloud.example.com"

# Set the base DN for the on-premises and cloud-based OpenLDAP servers
ON_PREM_BASE_DN="dc=on-premises,dc=example,dc=com"
CLOUD_BASE_DN="dc=cloud,dc=example,dc=com"

# Set the LDAP administrator bind DN and password
LDAP_ADMIN_DN="cn=admin,dc=on-premises,dc=example,dc=com"
LDAP_ADMIN_PASSWORD="password"

# Use LDAPSync to synchronize the on-premises and cloud-based OpenLDAP servers
ldapmodify -x -H "$ON_PREM_LDAP_SERVER" -D "$LDAP_ADMIN_DN" -w "$LDAP_ADMIN_PASSWORD" <<EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcSyncrepl
olcSyncrepl: rid=123 provider=$CLOUD_LDAP_SERVER type=refreshOnly interval=00:00:05:00 searchbase=$CLOUD_BASE_DN scope=sub bindmethod=simple binddn="$LDAP_ADMIN_DN" credentials=$LDAP_ADMIN_PASSWORD
EOF

# Restart the OpenLDAP server to apply the changes
systemctl restart slapd
