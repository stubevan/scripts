#!/bin/sh

set -e
set -u

ACME=${HOME}/.acme.sh/acme.sh
CERT=meesnas.romans-place.me.uk

echo "Issuing Renew"
${ACME} --renew -d ${CERT}

if [ $? = 0 ]; then
	echo "Certs Renewed - doing install"

	${ACME} --install-cert -d ${CERT} --cert-file ${HOME}/ssl/cert.pem --key-file ${HOME}/ssl/key.pem --fullchain-file ${HOME}/ssl/fullchain.pem

	chmod 400 ${HOME}/ssl/key.pem 
	sudo /bin/cp -p ${HOME}/ssl/key.pem /etc/certificates/Acme_MeesNas.key
	sudo /bin/cp -p ${HOME}/ssl/fullchain.pem /etc/certificates/Acme_MeesNas.crt
	sudo /usr/sbin/chown root /etc/certificates/*
	sudo /bin/chmod 400 /etc/certificates/Acme_MeesNas.key
	sudo /usr/local/sbin/nginx -s reload
fi

