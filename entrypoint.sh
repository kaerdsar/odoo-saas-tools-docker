#!/bin/bash

set -e

# Set odoo database host, port, user and password
: ${PGHOST:=${RDS_HOSTNAME:=${PGHOST:=${DB_PORT_5432_TCP_ADDR:='localhost'}}}}
: ${PGPORT:=${RDS_PORT:=${PGPORT:=${DB_PORT_5432_TCP_PORT:=5432}}}}
: ${PGDB:=${RDS_DB_NAME:=${PGDB:='postgres'}}}
: ${PGUSER:=${RDS_USERNAME:=${PGUSER:=${DB_ENV_POSTGRES_USER:='odoo'}}}}
: ${PGPASSWORD:=${RDS_PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${PGPASSWORD}}}}
export PGHOST PGPORT PGUSER PGPASSWORD PGDB

python /etc/odoo/makedb.py

# Generate UUID for the server database
uuid=$(cat /proc/sys/kernel/random/uuid)
# Update docker addons for odoo
sed -i "s/odoo.local/$SERVER_SUBDOMAIN:8069/g" /mnt/odoo-saas-tools/saas_server/data/ir_config_parameter.xml
sed -i "s/server_subdomain/$SERVER_SUBDOMAIN/g" /mnt/odoo-saas-tools/saas_portal_docker/data/server.xml
sed -i "s/server_client_id/$uuid/g" /mnt/odoo-saas-tools/saas_portal_docker/data/server.xml
sed -i "s/server_client_id/$uuid/g" /mnt/odoo-saas-tools/saas_server_docker/data/provider.xml

# Install docker modules on portal and server database
openerp-server -c /etc/odoo/openerp-server.conf -d $SERVER_SUBDOMAIN -i saas_server_docker --without-demo=all --stop-after-init
openerp-server -c /etc/odoo/openerp-server.conf -d $MAIN_DOMAIN -i saas_portal_docker --without-demo=all --stop-after-init

case "$1" in
	--)
		shift
		exec openerp-server "$@"
		;;
	-*)
		exec openerp-server "$@"
		;;
	*)
		exec "$@"
esac

exit 1