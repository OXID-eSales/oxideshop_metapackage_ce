#!/bin/bash
set -e
set -x
if [ -x vendor/bin/phpunit ]; then
  PHPUNIT=vendor/bin/phpunit
else
    if [ -x /var/www/vendor/bin/phpunit ]; then
        PHPUNIT=/var/www/vendor/bin/phpunit
    else
        echo "Can't find phpunit in vendor/bin or /var/www/vendor/bin"
        exit 1
    fi
fi
"${PHPUNIT}" \
    -c phpunit.xml \
    --bootstrap tests/bootstrap.php \
    --coverage-clover=tests/Reports/coverage_phpunit_unit.xml \
    --log-junit tests/Reports/phpunit-unit.xml \
    tests/Unit 2>&1 \
| tee tests/Output/unit_tests.txt
