#/bin/bash

# Script trace mode
if [ "${DEBUG_MODE}" == "true" ]; then
    set -o xtrace
fi

# usage: file_env VAR [DEFAULT]
# as example: file_env 'MYSQL_PASSWORD' 'zabbix'
#    (will allow for "$MYSQL_PASSWORD_FILE" to fill in the value of "$MYSQL_PASSWORD" from a file)
# unsets the VAR_FILE afterwards and just leaving VAR
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local defaultValue="${2:-}"

    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo "**** Both variables $var and $fileVar are set (but are exclusive)"
        exit 1
    fi

    local val="$defaultValue"

    if [ "${!var:-}" ]; then
        val="${!var}"
        echo "** Using ${var} variable from ENV"
    elif [ "${!fileVar:-}" ]; then
        if [ ! -f "${!fileVar}" ]; then
            echo "**** Secret file \"${!fileVar}\" is not found"
            exit 1
        fi
        val="$(< "${!fileVar}")"
        echo "** Using ${var} variable from secret file"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

# Set root password
file_env ROOT_PASSWORD
if [ -n "${ROOT_PASSWORD}" ]; then
    echo Setting root password...
    echo root:${ROOT_PASSWORD}|chpasswd
    unset -v ROOT_PASSWORD
fi

# Set SSHD Listen port
if [ -n "${SSHD_PORT}" ]; then
    echo Setting SSHD Listen port to ${SSHD_PORT}
    sed -i "s/^#\?Port [1-9]\+$/Port ${SSHD_PORT}/" /etc/ssh/sshd_config
fi