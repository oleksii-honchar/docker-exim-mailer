#!/bin/bash
BLUE='\033[0;34m'
LBLUE='\033[1;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

printf "${LBLUE}Update exim4 settings...${NC}\n"

echo "$MAILNAME" > /etc/mailname
cp /etc/aliases.stub /etc/aliases
echo "root: $POSTMASTER" >> /etc/aliases

/usr/bin/newaliases

if [ -n "$RELAY_HOST" ]; then
    SMART_HOST=${RELAY_HOST}::${RELAY_PORT:-25}
    sed -i s/{config_type}/satellite/ /etc/exim4/update-exim4.conf.conf
    sed -i s/{smart_host}/${SMART_HOST}/ /etc/exim4/update-exim4.conf.conf
else
    sed -i s/{config_type}/internet/ /etc/exim4/update-exim4.conf.conf
    sed -i s/{smart_host}// /etc/exim4/update-exim4.conf.conf
fi

if [ -n "$RELAY_USERNAME" ]; then
    echo "*:${RELAY_USERNAME}:${RELAY_PASSWORD}" > /etc/exim4/passwd.client
fi

printf "${LBLUE}Update exim4 config...${NC}\n"

update-exim4.conf

chown -R Debian-exim /var/spool/exim4
chown -R Debian-exim /var/mail

if [ $? -eq 0 ]; then
    printf "${GREEN}Executing docker cmd...${NC}\n"
		exec "$@"
else
  printf "${RED}[ERROR] Can't start docker.${NC}\n"
fi