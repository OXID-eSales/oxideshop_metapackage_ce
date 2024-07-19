#!/bin/bash
set -e
export XDEBUG_MODE=coverage

if [ -z "${SUITE}" ]; then
    SUITE=tests/Unit
fi

if [ -z "${ABSOLUTE_PATH}" ]; then
    ABSOLUTE_PATH="$(pwd)"
else
    ABSOLUTE_PATH="/var/www/${ABSOLUTE_PATH}"
fi

[[ ! -d "${ABSOLUTE_PATH}/tests/Output" ]] && mkdir "${ABSOLUTE_PATH}/tests/Output"
[[ ! -d "${ABSOLUTE_PATH}/tests/Reports" ]] && mkdir "${ABSOLUTE_PATH}/tests/Reports"

PHPUNIT="vendor/bin/phpunit"
if [ ! -f "${PHPUNIT}" ]; then
    PHPUNIT="/var/www/${PHPUNIT}"
    if [ ! -f "${PHPUNIT}" ]; then
        echo -e "\033[0;31mCould not find phpunit in vendor/bin or /var/www/vendor/bin\033[0m"
        exit 1
    fi
fi
BOOTSTRAP="/var/www/tests/bootstrap.php"
if [ ! -f "${BOOTSTRAP}" ]; then
    BOOTSTRAP="/var/www/vendor/oxideshop-ce/tests/bootstrap.php"
    if [ ! -f "${BOOTSTRAP}" ]; then
        echo -e "\033[0;31mCould not find bootstrap.php in /var/www/tests or /var/www/vendor/oxid-esales/oxideshop-ce/tests\033[0m"
        find /var/www -iname "bootstrap.php"
        exit 1
    fi
fi
"${PHPUNIT}" \
    -c tests/phpunit.xml \
    --bootstrap "${ABSOLUTE_PATH}/${BOOTSTRAP}" \
    --coverage-clover="${ABSOLUTE_PATH}/tests/Reports/coverage_phpunit_unit.xml" \
    --log-junit "${ABSOLUTE_PATH}/tests/Reports/phpunit-unit.xml" \
    "${SUITE}" 2>&1 \
| tee "${ABSOLUTE_PATH}/tests/Output/unit_tests.txt"
RESULT=$?
echo "phpunit exited with error code ${RESULT}"
if [ ! -s "${ABSOLUTE_PATH}/tests/Output/unit_tests.txt" ]; then
    echo -e "\033[0;31mLog file is empty! Seems like no tests have been run!\033[0m"
    RESULT=1
fi
cat >"${ABSOLUTE_PATH}/unit_failure_pattern.tmp" <<EOF
fail
\\.\\=\\=
Warning
Notice
Deprecated
Fatal
Error
DID NOT FINISH
Test file ".+" not found
Cannot open file
No tests executed
Could not read
Warnings: [1-9][0-9]*
Errors: [1-9][0-9]*
Failed: [1-9][0-9]*
Deprecations: [1-9][0-9]*
Risky: [1-9][0-9]*
EOF
sed -e 's|(.*)\r|$1|' -i "${ABSOLUTE_PATH}/unit_failure_pattern.tmp"
while read -r LINE ; do
    if [ -n "${LINE}" ]; then
        if grep -q -E "${LINE}" "${ABSOLUTE_PATH}/tests/Output/unit_tests.txt"; then
            echo -e "\033[0;31m unit test failed matching pattern ${LINE}\033[0m"
            grep -E "${LINE}" "${ABSOLUTE_PATH}/tests/Output/unit_tests.txt"
            RESULT=1
        else
            echo -e "\033[0;32m unit test passed matching pattern ${LINE}"
        fi
    fi
done <"${ABSOLUTE_PATH}/unit_failure_pattern.tmp"
if [[ ! -s "${ABSOLUTE_PATH}/tests/Reports/coverage_phpunit_unit.xml" ]]; then
    echo -e "\033[0;31m coverage report ${ABSOLUTE_PATH}/tests/Reports/coverage_phpunit_unit.xml is empty\033[0m"
    RESULT=1
fi
exit ${RESULT}
