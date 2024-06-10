#!/bin/bash
set -e
set -x
if [ -x vendor/bin/codecept ]; then
  CODECEPT=vendor/bin/codecept
else
    if [ -x /var/www/vendor/bin/codecept ]; then
        CODECEPT=/var/www/vendor/bin/codecept
    else
        echo "Can't find codecept in vendor/bin or /var/www/vendor/bin"
        exit 1
    fi
fi
"${CODECEPT}" build \
    -c tests/codeception.yml
"${CODECEPT}" run acceptanceSetup \
    -c tests/codeception.yml \
    --ext DotReporter 2>&1 \
| tee tests/Output/codeception_ShopSetup.txt
