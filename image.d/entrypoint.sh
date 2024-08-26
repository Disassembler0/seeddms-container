#!/bin/sh
set -e

if [ "$*" != "" ]; then
    exec "$@"
fi

echo "Starting SeedDMS..."

# Fix volume permissions
chown -R seeddms:seeddms /srv/seeddms/conf /srv/seeddms/data

# Populate database
export PGPASSWORD=${POSTGRES_PASSWORD}
DB_EXISTS=$(psql -h "${POSTGRES_HOST}" -Atc "SELECT 1 FROM \"tblVersion\"" "${POSTGRES_DB}" "${POSTGRES_USER}" 2>/dev/null || true)
if [ -z "${DB_EXISTS}" ]; then
    echo "Populating database..."
    cat /srv/seeddms/seeddms/install/create_tables-postgres.sql | psql -h "${POSTGRES_HOST}" "${POSTGRES_DB}" "${POSTGRES_USER}" >/dev/null
    cat /srv/seeddms/seeddms/install/custom.sql | psql -h "${POSTGRES_HOST}" "${POSTGRES_DB}" "${POSTGRES_USER}" >/dev/null
fi
# Update admin
if [ -n "${SEEDDMS_ADMIN_USER}" ]; then
    psql -h "${POSTGRES_HOST}" -Atc "UPDATE \"tblUsers\" SET login = '${SEEDDMS_ADMIN_USER}' WHERE id = 1" "${POSTGRES_DB}" "${POSTGRES_USER}" >/dev/null
fi
if [ -n "${SEEDDMS_ADMIN_PASSWORD}" ]; then
    psql -h "${POSTGRES_HOST}" -Atc "UPDATE \"tblUsers\" SET pwd = MD5('${SEEDDMS_ADMIN_PASSWORD}') WHERE id = 1" "${POSTGRES_DB}" "${POSTGRES_USER}" >/dev/null
fi
if [ -n "${SEEDDMS_ADMIN_EMAIL}" ] ; then
    psql -h "${POSTGRES_HOST}" -Atc "UPDATE \"tblUsers\" SET email = '${SEEDDMS_ADMIN_EMAIL}' WHERE id = 1" "${POSTGRES_DB}" "${POSTGRES_USER}" >/dev/null
fi
# TODO: Update database
# Looks like database schema updates are done only in new minor version (e.g. 6.0.x -> 6.1.x)
unset PGPASSWORD

# Configure SeedDMS
php -f /srv/seeddms/settings-from-env-vars.php
chown seeddms:seeddms /srv/seeddms/conf/settings.xml 

# Exec into s6 supervisor
exec /bin/s6-svscan /etc/services.d
