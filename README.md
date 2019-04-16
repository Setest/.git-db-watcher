Simple database version control
====================

If you working alone or in small group of people, and create projects which working
with MySQL databases, you can easily control of each state on every
stage of your project. This small component working in BASH enveronment, and can
be run in almost every web servers. Just install it, prepare config, and work as
usual with GIT. Or you can use it only for creating backups of your data. Feel the
freedom of total control!

### Main features

  You can hold under entirely control full database, or just partly:
  - only selected tables
  - almost all tables except severals
  - even exclude partly fields if you need and set there default values as it
    config it in your database.
  - and you can create only structure of selected tables if you need to hold their empty
  - hold different configuration in one config file
  - create CRON jobs and run as your wish with any configuration. E.g.: you need
    to backups only users data every day, and backup event manager journal once a week.

---

 - **[Installation](#installation)**
 - **[Basic Usage](#basic-usage)**
    - [Add custom provider](#add-custom-provider)
    - [Config INI](#config-ini)
 - [FAQ](#faq)
 - [TODO](#todo)
 - [Credits](#credits)
 - [Post scriptum](#ps)
 - [Donation](#donation)

### Installation

  You must copy [.git-db-watcher](https://github.com/Setest/.git-db-watcher) on your project
  which is an git work project.

  Or just run clone it to your working project.
  ```
  git clone https://github.com/Setest/.git-db-watcher
  ```

  If you using Git, you can add this project in your project as submodule:
  ```
  git submodule add git://github.com/Setest/.git-db-watcher.git .git-db-watcher
  ```

  Also if you a using git in your project, it will be better to add changes in **.gitignore**:
  ```
  .git-db-watcher/*
  !.git-db-watcher/backups/db.sql
  ```

  Make install script executable:
  ```
  chmod +x install.sh;
  ```

  After it you can install it with git hooks in your local computer, just run
  ```
  ./install.sh
  ```
  If you dont need use hooks, add **-nh** key.


  Put this files either in developer server. Change permissions and
  install there with key **-nh**
  ```
  ./install.sh -nh
  ```

  If you using DB on other host, i hightly recommended you create ssh keys to
  connect with server which contains current database server.

  Edit **config.ini** file.

  Change

### Basic Usage

  As usual, just make commit and checkout.

  Also you can dump database with run `./export.sh` in your local machine, and
  if you need to restore it in last condition, execute `./import.sh`. Both of this
  scripts by default working with project **config.ini** file. In ever moment you can run
  each of what with additional options, which is expand current config options.
  Also you can create your own different groups of options in config file with different names
  and run it use option `-c` or `-config`. Exp:
  ```
  ./import.sh --config=only_users
  ```

#### Config INI

  **Its very important** to config this file properly, because in several moment it
  use delete comand `find "$DB_BACKUP_PATH" -mindepth 1 -delete > /dev/null` which
  **can destroy your data!!!** Be very attentively when you put `DB_BACKUP_PATH` variable
  or `DB_BACKUP_PATH_TMP`!!! I highly recommend never doing that!!!

  More examples you can find in [config_example.ini](https://github.com/Setest/.git-db-watcher/blob/master/config_example.ini)

#### Add custom provider

для этого нужно написать свой файл провайдера по аналогии с имеющимися,
положить его в каталог providers и прописать в INI файле `PROVIDER=[название файла]`


### FAQ

  - Как экспортировать БД если она крутиться на локальном компе?
  - Мне нужно сохранить результат на сервере в другое место:
    ```
    ./db_export.sh --output 1>./xxx.sql
    ```
  - Хочу производить экспорт на сервере используя данные своего раздела файла
    конфигурации:
    ```
    ./db_export.sh -с=only_users --output 1>./users.sql
    ```
  - Хочу импортировать файл БД, но не хочу это делать через перехватчики GIT-а?
      - ```./import.sh```
      - `./import.sh EXPORT_FILE=site_name.sql`
      - `./import.sh DB_BACKUP_FILE=/.../../site_name.sql`
      - `./import.sh --config=site DB_BACKUP_FILE=./site_name.sql`
  - A как производить импорт находясь на сервере?
    ```
    ./db_import.sh < db_backup/db.sql
    ```
  - В разных проектах я использую CMS xxx и мне надоело каждый раз вводить данные
    для управления БД, как можно упростить процесс?
      Для этого нужно написать свой файл провайдера по аналогии с имеющимися.
  - Я создал задание CRON но оно не выполняется, либо кеш сайта CMS не очищается,
    в чем может быть дело?
    В зависимости от настроек сервера и самого задания, задания CRON могут запускаться
    совсем в другом окружении, в котором путь к php препроцессору может отличаться
    и как следствие, запускать совсем другую версию php не совместимую с той
    на которой работает ваша CMS.

### TODO

  * Использовать lockfile для предотвращения одновременного доступа к записи на сервер
    https://linux.die.net/man/1/lockfile
  * конфигурационные параметры значения которых разделяются пробелом, исправить так
    чтобы их можно было передавать через CLI
  * исправить отображение AUTO_INCREMENT при обработке DB_TABLES_REMOVE_INSERT
  * добавить установку через COMPOSER


### Credits

  I am very grateful to the guys who created these projects, it really helped in
  the development of this project, and just to understand the BASH and how to cook it.

  * [bash_ini_parser](https://github.com/albfan/bash-ini-parser/)
  * [.versioning](https://github.com/evandrocoan/.versioning/)


### PS

  Если у вас есть идеи как можно улучшить код, пишите в коментах, а лучше форкайте
  проект и присоедняйтесь к разработке!


## Donation

If this package helped you reduce your time to develop something, or it solved any major problems you had, feel free give me a cup of coffee :)

 - [![Yandex money](https://img.shields.io/badge/Yandex-donate-yellow.svg)](https://money.yandex.ru/to/410011611678383?default-sum=200)
