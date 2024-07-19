#!/bin/bash
set -x
if [ -z "${ABSOLUTE_PATH}" ]; then
    ABSOLUTE_PATH="$(pwd)"
else
    ABSOLUTE_PATH="/var/www/${ABSOLUTE_PATH}"
fi

[[ ! -d "${ABSOLUTE_PATH}/tests/Reports" ]] && mkdir "${ABSOLUTE_PATH}/tests/Reports"

if [ -x vendor/bin/phpcs ]; then
  PHPCS=vendor/bin/phpcs
else
    if [ -x /var/www/vendor/bin/phpcs ]; then
          PHPCS=/var/www/vendor/bin/phpcs
    else
        echo "Can't find phpcs in vendor/bin or /var/www/vendor/bin"
        exit 1
    fi
fi
"${PHPCS}" \
    --standard="${ABSOLUTE_PATH}/tests/phpcs.xml" \
    --report=json \
    --report-file="${ABSOLUTE_PATH}/tests/Reports/phpcs.report.json" \
||true
# As the first one does not produce legible output, this gives us something to see in the log
"${PHPCS}" \
    --standard="${ABSOLUTE_PATH}/tests/phpcs.xml" \
    --report=full
