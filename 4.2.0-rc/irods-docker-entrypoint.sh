#!/usr/bin/env bash
set -e

IRODS_CONFIG_FILE=/irods.config

set_postgres_params() {
    # set postgres-docker-entrypoint.sh variables to coincide with iRODS variables unless explicitly defined
    if [[ -z "${POSTGRES_PASSWORD}" ]]; then
        gosu root sed -i 's/POSTGRES_PASSWORD/IRODS_DATABASE_PASSWORD/g' /postgres-docker-entrypoint.sh
    fi
    if [[ -z "${POSTGRES_USER}" ]]; then
        gosu root sed -i 's/POSTGRES_USER/IRODS_DATABASE_USER_NAME/g' /postgres-docker-entrypoint.sh
    fi
    if [[ -z "${POSTGRES_DB}" ]]; then
        gosu root sed -i 's/POSTGRES_DB/IRODS_DATABASE_NAME/g' /postgres-docker-entrypoint.sh
    fi
}

generate_config() {
    DATABASE_HOSTNAME_OR_IP=$(/sbin/ip -f inet -4 -o addr | grep eth | cut -d '/' -f 1 | rev | cut -d ' ' -f 1 | rev)
    echo "${IRODS_SERVICE_ACCOUNT_NAME}" > ${IRODS_CONFIG_FILE}
    echo "${IRODS_SERVICE_ACCOUNT_GROUP}" >> ${IRODS_CONFIG_FILE}
    echo "1" >> ${IRODS_CONFIG_FILE} # iRODS server's role
    echo "2" >> ${IRODS_CONFIG_FILE} # ODBC driver for postgres
    echo "${IRODS_DATABASE_SERVER_HOSTNAME}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_DATABASE_SERVER_PORT}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_DATABASE_NAME}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_DATABASE_USER_NAME}" >> ${IRODS_CONFIG_FILE}
    echo "yes" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_DATABASE_PASSWORD}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_DATABASE_USER_PASSWORD_SALT}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_ZONE_NAME}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_PORT}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_PORT_RANGE_BEGIN}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_PORT_RANGE_END}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_CONTROL_PLANE_PORT}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_SCHEMA_VALIDATION}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_SERVER_ADMINISTRATOR_USER_NAME}" >> ${IRODS_CONFIG_FILE}
    echo "yes" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_SERVER_ZONE_KEY}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_SERVER_NEGOTIATION_KEY}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_CONTROL_PLANE_KEY}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_SERVER_ADMINISTRATOR_PASSWORD}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_VAULT_DIRECTORY}" >> ${IRODS_CONFIG_FILE}
}

if [[ "$1" = 'setup_irods.sh' ]]; then
    # Configure PostgreSQL
    set_postgres_params
    ./postgres-docker-entrypoint.sh postgres &
    sleep 10s

    # Generate iRODS config file
    generate_config

    # Setup iRODS
    if [[ "$1" = 'setup_irods.sh' ]] && [[ "$#" -eq 1 ]]; then
        # Configure with environment variables
        gosu root python /var/lib/irods/scripts/setup_irods.py < ${IRODS_CONFIG_FILE}
    else
        # TODO: Configure with file
        gosu root python /var/lib/irods/scripts/setup_irods.py < ${IRODS_CONFIG_FILE}
    fi

    # Keep container alive
    echo "### iRODS is now running ###"
    tail -f /dev/null
else
    set_postgres_params
    exec "$@"
fi

exit 0;