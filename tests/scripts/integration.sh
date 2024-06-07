#!/bin/bash
set -e
set -x
vendor/bin/phpunit \
    -c phpunit.xml \
    --bootstrap tests/bootstrap.php \
    --coverage-clover=tests/Reports/coverage_phpunit_integration.xml \
    tests/Integration 2>&1 \
| tee tests/Output/integration_tests.txt
