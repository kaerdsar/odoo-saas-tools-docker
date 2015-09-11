FROM odoo
USER root

# Install dependencies
RUN set -x; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
       python-oauthlib python-openssl python-ndg-httpsclient python-pyasn1 python-pip git-core \
    && pip install inflect

# Download Odoo SaaS Tools Addons
RUN git clone -b upstream https://github.com/kaerdsar/odoo-saas-tools.git /mnt/odoo-saas-tools

# Add Odoo Docker Addons
COPY addons /mnt/odoo-saas-docker/

# Update Odoo Conf
COPY conf/openerp-server.conf /etc/odoo/
RUN chown odoo /etc/odoo/openerp-server.conf

# Copy python script
COPY makedb.py /etc/odoo/
RUN chown odoo /etc/odoo/makedb.py

# Set default user when running the container
USER odoo

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["openerp-server"]
