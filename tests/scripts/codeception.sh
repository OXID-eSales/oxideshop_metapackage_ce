#!/bin/bash
set -e
if [ -z "${ABSOLUTE_PATH}" ]; then
    ABSOLUTE_PATH="$(pwd)"
else
    ABSOLUTE_PATH="/var/www/${ABSOLUTE_PATH}"
fi

[[ ! -d "${ABSOLUTE_PATH}/tests/Output" ]] && mkdir "${ABSOLUTE_PATH}/tests/Output"

if [ -z "${SELENIUM_SERVER_HOST}" ]; then
    SELENIUM_SERVER_HOST='selenium'
fi

if [ -z "${SUITE}" ]; then
    SUITE="Acceptance"
    if [ ! -d "${ABSOLUTE_PATH}/tests/Codeception/${SUITE}" ]; then
        SUITE="acceptance"
        if [ ! -d "${ABSOLUTE_PATH}/tests/Codeception/${SUITE}" ]; then
            echo -e "\033[0;31mCould not find suite Acceptance or acceptance in tests/Codeception\033[0m"
            exit 1
        fi
    fi
fi

CODECEPT="vendor/bin/codecept"
if [ ! -f "${CODECEPT}" ]; then
    CODECEPT="/var/www/${CODECEPT}"
    if [ ! -f "${CODECEPT}" ]; then
        echo -e "\033[0;31mCould not find codecept in vendor/bin or /var/www/vendor/bin\033[0m"
        exit 1
    fi
fi
# wait for selenium host
I=60
until  [ $I -le 0 ]; do
    curl -sSjkL "http://${SELENIUM_SERVER_HOST}:4444/wd/hub/status" |grep '"ready": true' && break
    echo "."
    sleep 1
    ((I--))
done
set -e
curl -sSjkL "http://${SELENIUM_SERVER_HOST}:4444/wd/hub/status"

"${CODECEPT}" build \
    -c "${ABSOLUTE_PATH}/tests/codeception.yml"
RESULT=$?
echo "Codecept build exited with error code ${RESULT}"
"${CODECEPT}" run "${SUITE}" \
    -c "${ABSOLUTE_PATH}/tests/codeception.yml" \
    --ext DotReporter \
    -o "paths: output: ${ABSOLUTE_PATH}/tests/Output" 2>&1 \
| tee "${ABSOLUTE_PATH}/tests/Output/codeception_${SUITE}.txt"
RESULT=$?
echo "Codecept run exited with error code ${RESULT}"

find "${ABSOLUTE_PATH}/tests/Codeception/_output" -type f -exec cp \{\} "${ABSOLUTE_PATH}/tests/Output/" \;
if [ ! -s "${ABSOLUTE_PATH}/tests/Output/codeception_${SUITE}.txt" ]; then
    echo -e "\033[0;31mLog file is empty! Seems like no tests have been run!\033[0m"
    RESULT=1
fi
cat >"${ABSOLUTE_PATH}/codeception_failure_pattern.tmp" <<EOF
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
sed -e 's|(.*)\r|$1|' -i "${ABSOLUTE_PATH}/codeception_failure_pattern.tmp"
while read -r LINE ; do
    if [ -n "${LINE}" ]; then
        if grep -q -E "${LINE}" "${ABSOLUTE_PATH}/tests/Output/codeception_${SUITE}.txt"; then
            echo -e "\033[0;31m codecept ${SUITE} failed matching pattern ${LINE}\033[0m"
            grep -E "${LINE}" "${ABSOLUTE_PATH}/tests/Output/codeception_${SUITE}.txt"
            RESULT=1
        else
            echo -e "\033[0;32m codeception passed matching pattern ${LINE}"
        fi
    fi
done <"${ABSOLUTE_PATH}/codeception_failure_pattern.tmp"
exit ${RESULT}
