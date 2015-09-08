FROM odoo

# Install dependencies
RUN set -x; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
       python-inflect \
       python-oauthlib \
       python-pip \
       git-core
    && pip install requests[security] \
    && pip install erppeek

# Download Odoo SaaS Tools Addons
RUN git clone https://github.com/kaerdsar/odoo-saas-tools.git /mnt/odoo-saas-tools

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
