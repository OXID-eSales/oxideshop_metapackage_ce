#!/bin/bash
set -x
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
"${PHPSTAN}" -ctests/PhpStan/phpstan.neon analyse src/ \
  --error-format=json >phpstan.report.json
