Simple database version control
====================

If you working alone or in small group of people, and create projects which working
with mySQL databases, you can easily control of each state on every
stage of your project. This small component working in BASH enveronment, and can
be run in almost every web servers. Just install it, prepare config, and work as
usual with GIT.

---

 - **[Installation](#installation)**
 - **[Basic Usage](#basic-usage)**
    - [Add custom provider](#add-custom-provider)
    - [Config INI](#config-ini)
 - [FAQ](#faq)
 - [TODO](#todo)
 - [Credits](#credits)
 - [Donation](#donation)

### Installation

  You must copy [.git-db-watcher](https://github.com/Setest/.git-db-watcher) on your project which is an git work project.
  Or just run: `git clone https://github.com/Setest/.git-db-watcher` in your working project.

  After it you can install git hooks, just run `./install_githooks.sh`

  If you using DB on other host, i hightly recommended you create ssh keys to
  connect with server which contains current database server.

  Edit **config.ini** file.

### Basic Usage

  As usual, just make commit and checkout.

  Also you can dump database with run `./export.sh` in your local machine, and
  if you need to restore it in last condition, execute `./import.sh`. Both of this
  scripts by default working with project **config.ini** file. In ever moment you can run
  each of what with additional options, which is expand current config options.
  Also you can create your own different groups of options in config file with different names
  and run it use option `-c` or `-config`. Exp: `./import.sh --config=only_users`

#### Config INI

  More examples you can find in [config_example.ini](https://github.com/Setest/.git-db-watcher/blob/master/config_example.ini)

#### Add custom provider

для этого нужно написать свой файл провайдера по аналогии с имеющимися,
положить его в каталог providers и прописать в INI файле `PROVIDER=[название файла]`


### FAQ

  - Как экспортировать БД если она крутиться на локальном компе
  - Хочу импортировать файл БД, но не хочу это делать через перехватчики GIT-а
      - `./import.sh`
      - `./import.sh EXPORT_FILE=site_name.sql`
      - `./import.sh DB_BACKUP_FILE=/.../../site_name.sql`
      - `./import.sh --config=site DB_BACKUP_FILE=./site_name.sql`
  - A как производить импорт находясь на сервере:
    ./db_import.sh < db_backup/db.sql
  - В разных проектах я использую CMS xxx и мне надоело каждый раз вводить данные
    для управления БД, как можно упростить процесс?
      Для этого нужно написать свой файл провайдера по аналогии с имеющимися.

### TODO

  * конфигурационные параметры значения которых разделяются пробелом, исправить так
    чтобы их можно было пердавать через CLI
  * исправить отображение AUTO_INCREMENT при обработке DB_TABLES_REMOVE_INSERT
  * добавить установку через COMPOSER


### Credits

  * [bash_ini_parser](https://raw.githubusercontent.com/albfan/bash-ini-parser/)
  * [.versioning](https://github.com/evandrocoan/.versioning/)


## Donation

If this package helped you reduce your time to develop something, or it solved any major problems you had, feel free give me a cup of coffee :)

 - [![Yandex money](https://img.shields.io/badge/Yandex-donate-yellow.svg)](https://money.yandex.ru/to/410011611678383)


<iframe src="https://money.yandex.ru/quickpay/button-widget?targets=%D0%90%D1%84%D1%84%D1%82%D0%B0%D1%80%2C%20%D0%B6%D0%B3%D0%B8%20%D0%B8%D1%81%D1%87%D0%BE!&default-sum=200&button-text=13&yamoney-payment-type=on&button-size=s&button-color=orange&successURL=&quickpay=small&account=410011611678383&" width="127" height="25" frameborder="0" allowtransparency="true" scrolling="no"></iframe>

