#!/bin/bash
set -x
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
"${PHPMD}" src json tests/PhpMd/standard.xml \
  --ignore-errors-on-exit \
  --ignore-violations-on-exit \
  --reportfile phpmd.report.json
