import os

from psycopg2 import connect
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

conn = connect(
    dbname=os.environ['PGDB'],
    user=os.environ['PGUSER'],
    host=os.environ['PGHOST'],
    port=os.environ['PGPORT'],
    password=os.environ['PGPASSWORD'],
)

conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
cr = conn.cursor()
cr.execute('CREATE DATABASE "{}" OWNER {};'.format(os.environ['MAIN_DOMAIN'], os.environ['PGUSER']))
cr.execute('CREATE DATABASE "{}" OWNER {};'.format(os.environ['SERVER_SUBDOMAIN'], os.environ['PGUSER']))
cr.close()
conn.close()