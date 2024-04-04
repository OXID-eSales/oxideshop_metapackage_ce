# Testplans for Compilations
As we have a lot of moving parts here across the various versions, I have created a couple of sub directories for the different scenarios
and shared configurations. The following chapters describe those scenarios.

Below that, there are instructions on how to add tests for more components after you added them to composer.json.

## Scenarios

### 80full: Shop b-8.0.x, testing all components and modules
This scenario tests the shop and modules and also runs all tests of the other
components. To invoke it, use the following testplan combination:
```
https://raw.githubusercontent.com/OXID-eSales/oxideshop_metapackage_ce/b-8.0/composer.json,~/80full/metapackage.yml
```
You can prepend one of the following default templates to limit the test runs to one combination of PHP/MySQL:
* ~/defaults/php8.1_mysql5.7_only.yml
* ~/defaults/php8.1_mysql8.0_only.yml
* ~/defaults/php8.2_mysql5.7_only.yml
* ~/defaults/php8.2_mysql8.0_only.yml

### 80slim: Shop b-8.0.x, testing only shop and modules
This scenario only runs the tests from the shop and the modules. To invoke it, use the following test plan combination:
```
https://raw.githubusercontent.com/OXID-eSales/oxideshop_metapackage_ce/b-8.0/composer.json,~/80slim/metapackage.yml
```
You can one of the default templates mentioned above to limit the  test runs to one combination of PHP/MySQL as well.

### 71full: Shop b-7.1.x, testing all components and modules
This scenario tests the shop and modules and also runs all tests of the other
components. To invoke it, use the following testplan combination:
```
~/defaults/7.1.x.yml,https://raw.githubusercontent.com/OXID-eSales/oxideshop_metapackage_ce/b-7.1/composer.json,~/71full/metapackage.yml
```
You can add one of the following default templates **AFTER the 7.1.x default template** to limit the test runs to one combination of PHP/MySQL:
* ~/defaults/php8.1_mysql5.7_only.yml
* ~/defaults/php8.1_mysql8.0_only.yml
* ~/defaults/php8.2_mysql5.7_only.yml
* ~/defaults/php8.2_mysql8.0_only.yml

### 71slim: Shop b-7.1.x, only shop and modules
This scenario only runs the tests from the shop and the modules. To invoke it, use the following test plan combination:
```
~/defaults/7.1.x.yml,https://raw.githubusercontent.com/OXID-eSales/oxideshop_metapackage_ce/b-7.1/composer.json,~/71slim/metapackage.yml
```
You can add one of the following default templates mentioned in the 71full chapter **AFTER the 7.1.x default template** to limit the test runs to one combination of PHP/MySQL as well.

### 70full: Shop b-7.0.x, testing all components and modules
This scenario tests the shop and modules and also runs all tests of the other
components. To invoke it, use the following testplan combination:
```
~/defaults/7.0.x.yml,https://raw.githubusercontent.com/OXID-eSales/oxideshop_metapackage_ce/b-7.0/composer.json,~/70full/metapackage.yml
```
You can add one of the following default templates **AFTER the 7.0.x default template** to limit the test runs to one combination of PHP/MySQL:
* ~/defaults/php8.0_mysql5.7_only.yml
* ~/defaults/php8.0_mysql8.0_only.yml
* ~/defaults/php8.1_mysql5.7_only.yml
* ~/defaults/php8.1_mysql8.0_only.yml

### 70slim: Shop b-7.0.x, only shop and modules
This scenario only runs the tests from the shop and the modules. To invoke it, use the following test plan combination:
```
~/defaults/7.0.x.yml,https://raw.githubusercontent.com/OXID-eSales/oxideshop_metapackage_ce/b-7.0/composer.json,~/70slim/metapackage.yml
```
You can add one of the following default templates mentioned in the 70full chapter **AFTER the 7.0.x default template** to limit the test runs to one combination of PHP/MySQL as well.

### 70dev: Development branches of Shop b-7.0.x and modules
This scenario uses the b-7.0-dev branch of this repo which contains a stripped down composer.json using the dev-b7.0.x branches for shop and modules instead of explicit released
version numbers. To invoke it, use the following test plan combination:
```
~/defaults/7.0.x.yml,https://raw.githubusercontent.com/OXID-eSales/oxideshop_metapackage_ce/b-7.0-dev/composer.json,~/70dev/metapackage.yml
```
You can add one of the following default templates mentioned in the 70full chapter **AFTER the 7.0.x default template** to limit the test runs to one combination of PHP/MySQL as well.

## Adding modules to the testing workflow(s)
Ideally, it would be sufficient to only edit composer.json and be done with it. Due to the limitations of github actions and our workflows,
we are not that smart yet to automatically ose composer.json to find out what should be tested and how it should be tested. So, when you
add something new to composer.json, you need to configure the testplans to test them.

### Add module install config
You need to add a install_<whatever>.yml to the relevant scenarios (e.g. 70full and 70slim for the b-7.0 70dev for b-7.0-dev and so on).
The install_*.yml files in those folders are a chain of install_module configurations, each loading the next one. which are used in
the install_module section of metapackage.yml in those folders. These chains are different for the different scenarios.

The install_<wharever>.yml needs to be added to the testplan matrix in the metapackage.yml in the scenario folder. Ideally, you add it as
the last component in the chain. You set "load_shop" in your new install_<whatever>.yml to the cache.prefix of the entry before.If your
module/component is not the last one in the cahin, you need to modify load_shop of its successor to load the cache generated by your new
install_<whatever>.yml. If your module is the last one in the testplan list, make sure to set load_shop of the phpunit section of
metapackage.yml to cache.prefix of your install_<whatever>.yml.

### Add test config
To actually execute tests, you need to add a <whatever>.yml and when needed <whatever>_integration.yml in the shared folder. These files
contain the actual test sections (phpunit, codeception, runtest, phpcs, styles and so on). These files need to be referenced in
metapackage.yml in the scenariuo folders as well.

Make sure to add the module ids to the module options of codeception.pre_script to ensure that the module is loaded when we run the
codeception tests. If there are entries in the autoload/autoload-dev sections of the component/modules composer.json, add them to
prepare_shop.composer.transform and make sure to have the correct path to the respective folders.
