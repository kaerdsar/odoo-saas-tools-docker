#!/bin/bash

# Start Postgresql server
/etc/init.d/postgresql start

if su postgres -c "psql -l | grep '$MAIN_DOMAIN'"
then
    echo 'Database Ready!!!'
else
    # Generate UUID for the server database
    uuid=$(cat /proc/sys/kernel/random/uuid)

    # Update docker addons for odoo
    sed -i "s/server_subdomain/$SERVER_SUBDOMAIN/g" /mnt/odoo-saas-tools/saas_portal_docker/data/server.xml
    sed -i "s/server_client_id/$uuid/g" /mnt/odoo-saas-tools/saas_portal_docker/data/server.xml
    sed -i "s/server_client_id/$uuid/g" /mnt/odoo-saas-tools/saas_server_docker/data/provider.xml

    # Create portal database
    su postgres -c "createdb -O odoo '$MAIN_DOMAIN'"
    su odoo -s /bin/bash -c "openerp-server -c /etc/odoo/openerp-server.conf -d '$MAIN_DOMAIN' -i saas_portal_docker --without-demo=all --stop-after-init"

    # Create server database
    su postgres -c "createdb -O odoo '$SERVER_SUBDOMAIN'"
    su odoo -s /bin/bash -c "openerp-server -c /etc/odoo/openerp-server.conf -d '$SERVER_SUBDOMAIN' -i saas_server_docker --without-demo=all --stop-after-init"
fi

# Stop Postgresql server
/etc/init.d/postgresql stop
