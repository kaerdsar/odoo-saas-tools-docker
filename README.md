# Odoo SaaS Tools Docker

Docker image for Odoo (OpenERP) addons to provide SaaS

## Install the latest Docker package. Verify that you have wget installed.

```console
$ wget -qO- https://get.docker.com/ | sh
```

## Build image for Odoo SaaS

```console
$ docker build -t odoo-saas .
```

## Start an Odoo SaaS instance

```console
$ docker run -e MAIN_DOMAIN=portal.com -e SERVER_SUBDOMAIN=server.portal.com -p 8069:8069 --name odoo -t odoo-saas
```

## Stop and restart an Odoo SaaS instance

```console
$ docker stop odoo
$ docker start -a odoo
```

## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/yelizariev/odoo-saas-tools-docker/issues).

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/yelizariev/odoo-saas-tools-docker/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.
