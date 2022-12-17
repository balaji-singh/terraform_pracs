# Set up the source and destination servers
SOURCE_SERVER=ldap1.example.com
DEST_SERVER=ldap2.example.com

# Set up the replication user
REPL_USER_DN="cn=admin,dc=s24,dc=com"
REPL_USER_PASSWORD=adminPassword

# Set up the database suffix
DATABASE_SUFFIX="dc=s24,dc=com"

# Export the data from the source server
ldapsearch -x -LLL -D "$REPL_USER_DN" -w "$REPL_USER_PASSWORD" -b "$DATABASE_SUFFIX" > data.ldif

# Import the data into the destination server
ldapadd -x -D "$REPL_USER_DN" -w "$REPL_USER_PASSWORD" -H ldap://$DEST_SERVER -f data.ldif

# Clean up
rm data.ldif
