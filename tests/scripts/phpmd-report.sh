#!/bin/bash
set -x
if [ -z "${ABSOLUTE_PATH}" ]; then
    ABSOLUTE_PATH="$(pwd)"
else
    ABSOLUTE_PATH="/var/www/${ABSOLUTE_PATH}"
fi

[[ ! -d "${ABSOLUTE_PATH}/tests/Reports" ]] && mkdir "${ABSOLUTE_PATH}/tests/Reports"

if [ -x vendor/bin/phpmd ]; then
  PHPMD=vendor/bin/phpmd
else
    if [ -x /var/www/vendor/bin/phpmd ]; then
          PHPMD=/var/www/vendor/bin/phpmd
    else
        echo "Can't find phpmd in vendor/bin or /var/www/vendor/bin"
        exit 1
    fi
fi
"${PHPMD}" src json "${ABSOLUTE_PATH}/tests/PhpMd/standard.xml" \
  --ignore-errors-on-exit \
  --ignore-violations-on-exit \
  --reportfile "${ABSOLUTE_PATH}/testsReports/phpmd.report.json"
