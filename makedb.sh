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
    sed -i "s/odoo.local/$MAIN_DOMAIN:8069/g" /mnt/odoo-saas-tools/saas_server/data/auth_oauth_data.xml
    sed -i "s/odoo.local/$SERVER_SUBDOMAIN:8069/g" /mnt/odoo-saas-tools/saas_server/data/ir_config_parameter.xml
    sed -i "s/server1.com</$SERVER_SUBDOMAIN</g" /mnt/odoo-saas-tools/saas_portal_demo_example/data/saas_portal_plan.xml
    sed -i "s/server_subdomain/$SERVER_SUBDOMAIN/g" /mnt/odoo-saas-docker/saas_portal_docker/data/server.xml
    sed -i "s/server_client_id/$uuid/g" /mnt/odoo-saas-docker/saas_portal_docker/data/server.xml
    sed -i "s/server_client_id/$uuid/g" /mnt/odoo-saas-docker/saas_server_docker/data/provider.xml

    # Update /etc/hosts
    echo "127.0.0.1    $MAIN_DOMAIN" >> /etc/hosts
    echo "127.0.0.1    $SERVER_SUBDOMAIN" >> /etc/hosts

    # Create server database
    su postgres -c "createdb -O odoo '$SERVER_SUBDOMAIN'"
    su odoo -s /bin/bash -c "openerp-server -c /etc/odoo/openerp-server.conf -d '$SERVER_SUBDOMAIN' -i saas_server_docker --without-demo=all --stop-after-init"

    # Create portal database
    su odoo -s /bin/bash -c "openerp-server -c /etc/odoo/openerp-server.conf"
    su postgres -c "createdb -O odoo '$MAIN_DOMAIN'"
    su odoo -s /bin/bash -c "openerp-server -c /etc/odoo/openerp-server.conf -d '$MAIN_DOMAIN' -i saas_portal_docker --xmlrpc-port=8079 --without-demo=all --stop-after-init"
    kill $(ps aux | grep 'openerp' | awk '{print $2}')

    # Update database template 1
    su odoo -s /bin/bash -c "openerp-server -c /etc/odoo/openerp-server.conf -d template_pos_product_available.'$SERVER_SUBDOMAIN' -i pos_product_available --without-demo=all --stop-after-init"

    # Update database template 2
    su odoo -s /bin/bash -c "openerp-server -c /etc/odoo/openerp-server.conf -d template_reminders_and_agenda.'$SERVER_SUBDOMAIN' -i reminder_task_deadline --without-demo=all --stop-after-init"

fi

# Stop Postgresql server
/etc/init.d/postgresql stop
