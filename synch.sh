# Set up the servers
MASTER_SERVER=ldap1.example.com
SLAVE_SERVER=ldap2.example.com

# Set up the replication user
REPL_USER_DN="cn=replicator,dc=example,dc=com"
REPL_USER_PASSWORD=replicator_password

# Set up the database suffix
DATABASE_SUFFIX="dc=example,dc=com"

# Set up the replication secret
REPLICATION_SECRET=replication_secret

# Add the replication user to the master server
ldapadd -x -D "$REPL_USER_DN" -w "$REPL_USER_PASSWORD" <<EOF
dn: $REPL_USER_DN
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: replicator
userPassword: $REPL_USER_PASSWORD
EOF

# Enable syncrepl on the master server
ldapmodify -x -D "$REPL_USER_DN" -w "$REPL_USER_PASSWORD" <<EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcSyncrepl
olcSyncrepl: rid=001 provider=ldap://$SLAVE_SERVER bindmethod=simple binddn="$REPL_USER_DN" credentials=$REPL_USER_PASSWORD searchbase="$DATABASE_SUFFIX" type=refreshAndPersist retry="60 +"
EOF

# Enable syncrepl on the slave server
ldapmodify -x -D "$REPL_USER_DN" -w "$REPL_USER_PASSWORD" <<EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcSyncrepl
olcSyncrepl: rid=001 provider=ldap://$MASTER_SERVER bindmethod=simple binddn="$REPL_USER_DN" credentials=$REPL_USER_PASSWORD searchbase="$DATABASE_SUFFIX" type=refreshAndPersist retry="60 +"
EOF

# Set up the replication secret on the slave server
ldapmodify -x -D "$REPL_USER_DN" -w "$REPL_USER_PASSWORD" <<EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcSyncRepl
olcSyncRepl: rid=001 provider=ldap://$MASTER_SERVER bindmethod=simple binddn="cn=admin,$DATABASE_SUFFIX" credentials=$REPLICATION_SECRET searchbase="$DATABASE_SUFFIX" type=refreshAndPersist retry="60 +"
EOF

# Set up the replication secret on the master server
ldapmodify -x -D "$REPL_USER_DN" -w "$REPL_USER_PASSWORD" <<EOF
dn: olcDatabase={1}mdb
