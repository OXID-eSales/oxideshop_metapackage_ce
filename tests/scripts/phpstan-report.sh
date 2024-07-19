#!/bin/bash
set -x
if [ -z "${ABSOLUTE_PATH}" ]; then
    ABSOLUTE_PATH="$(pwd)"
else
    ABSOLUTE_PATH="/var/www/${ABSOLUTE_PATH}"
fi

[[ ! -d "${ABSOLUTE_PATH}/tests/Reports" ]] && mkdir "${ABSOLUTE_PATH}/tests/Reports"

if [ -x vendor/bin/phpstan ]; then
  PHPSTAN=vendor/bin/phpstan
else
    if [ -x /var/www/vendor/bin/phpstan ]; then
          PHPSTAN=/var/www/vendor/bin/phpstan
    else
        echo "Can't find phpstan in vendor/bin or /var/www/vendor/bin"
        exit 1
    fi
fi
"${PHPSTAN}" -c"${ABSOLUTE_PATH}/tests/PhpStan/phpstan.neon" analyse src/ \
  --error-format=json >"${ABSOLUTE_PATH}/tests/Reports/phpstan.report.json"
