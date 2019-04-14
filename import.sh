#!/bin/bash
pushd `dirname $0` > /dev/null
PATH_PWD=`pwd`
popd > /dev/null

EVENT_NAME="DB MIGRATE IMPORT"
source $PATH_PWD/functions/common.sh
console_log event $EVENT_NAME

include $PATH_PWD/functions/bash-ini-parser/bash-ini-parser
# получаем переменные из ini
cfg_parser $PATH_PWD/config.ini
cfg_section_common
cfg_section_develop

include $PATH_PWD/functions/parse_args.sh
include $PATH_PWD/functions/vars.sh
include $PATH_PWD/functions/files.sh


if [ ! -x "$DB_BACKUP_FILE" ]
  then
    console_log ERROR "Локальный файл БД '${DB_BACKUP_FILE}' не существует либо отсутствуют разрешения на его чтение! Прерываю работу"
    exit 1;
fi

console_log "отправляю файл: ${DB_BACKUP_FILE}"

RESULTS=$(eval "${CLI_DB_IMPORT} < ${DB_BACKUP_FILE}")
err_num=$?
if (($err_num)); then
  console_log ERROR "[${err_num}] Возникла ошибка не могу создать файл БД!"
  console_log event $EVENT_NAME "\e[1mFINISHED\e[22m"
  exit $err_num;
else
  console_log warn "БД импортирована успешно!"
fi

console_log event $EVENT_NAME "FINISHED"
echo $RESULTS;
exit 0;
