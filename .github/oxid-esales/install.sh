#!/bin/bash
set +x
chmod a+x vendor/oxid-esales/oxideshop-ce/.github/oxid-esales/install.sh
ln -s vendor/oxid-esales/oxideshop-ce/bootstrap.php .
if [ ! -f source/config.inc.php.dist ]; then
    cp vendor/oxid-esales/oxideshop-ce/source/config.inc.php.dist source/
fi
if [ ! -f source/config.inc.php ]; then
    cp source/config.inc.php.dist source/source/config.inc.php
fi
bash -x vendor/oxid-esales/oxideshop-ce/.github/oxid-esales/install.sh
