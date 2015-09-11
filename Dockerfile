FROM debian:stable

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            nodejs \
            npm \
            python-support \
            python-pyinotify \
            python-oauthlib \
            python-oerplib \
            git-core \
        && npm install -g less less-plugin-clean-css \
        && ln -s /usr/bin/nodejs /usr/bin/node \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Configure APT packages and upgrade
RUN echo deb http://nightly.odoo.com/8.0/nightly/deb/ ./ > /etc/apt/sources.list.d/odoo-80.list
RUN apt-get update
RUN apt-get upgrade -y

# Locale setup (if not set, PostgreSQL creates the database in SQL_ASCII)
RUN echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections &&\
    echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections
RUN apt-get install locales -qq
RUN locale-gen en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install PostgreSQL, Odoo and Supervisor
RUN apt-get install --allow-unauthenticated -y supervisor postgresql odoo

# Download Odoo SaaS Tools Addons
RUN git clone https://github.com/yelizariev/odoo-saas-tools.git /mnt/odoo-saas-tools

# Download Pos Addons
RUN git clone https://github.com/yelizariev/pos-addons.git /mnt/pos-addons

# Download Reminder Addons
RUN git clone https://github.com/yelizariev/addons-yelizariev /mnt/yelizariev-addons

# Download Website Addons
RUN git clone https://github.com/yelizariev/website-addons /mnt/website-addons

# Add Odoo SaaS Docker Addons
COPY addons /mnt/odoo-saas-docker/

# Update Odoo Conf
COPY conf/openerp-server.conf /etc/odoo/
RUN chown odoo /etc/odoo/openerp-server.conf

# Clean
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# Create user and set permissions
RUN /etc/init.d/postgresql start && su postgres -c "createuser -s odoo"
RUN chown -R postgres.postgres /var/lib/postgresql
VOLUME ["/var/lib/postgresql"]

# Supervisor setup
ADD conf/10_postgresql.conf /etc/supervisor/conf.d/10_postgresql.conf
ADD conf/20_odoo.conf /etc/supervisor/conf.d/20_odoo.conf

EXPOSE 8069
ADD makedb.sh /makedb.sh
RUN chmod +x makedb.sh
CMD ./makedb.sh && /usr/bin/supervisord -n
