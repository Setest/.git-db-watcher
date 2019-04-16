#!/bin/bash

pushd `dirname $0` > /dev/null
PATH_PWD=`pwd`
popd > /dev/null

EVENT_NAME="db_import"
declare -A CONFIG


source $PATH_PWD/functions/common.sh
include $PATH_PWD/functions/files.sh
check_config

include $PATH_PWD/functions/bash-ini-parser/bash-ini-parser

cfg_parser $PATH_PWD/config.ini
cfg_section_common
cfg_section_server
cfg_section_hooks

# подгржаем файл глобальных переменных
include $PATH_PWD/functions/parse_args.sh $@
# source $PATH_PWD/functions/parse_args.sh
include $PATH_PWD/functions/vars.sh


console_log --color=bg_green event $EVENT_NAME

get_provider

console_log "Database is ${DB_CONFIG_HOST}:${DB_CONFIG_DBASE}"

get_host

TMPFILE=$(mktemp);

while IFS= read -t 1 -r LINE; do
  printf '%s\n' "${LINE}" >> ${TMPFILE}
done < <(grep "" /dev/stdin)


if [ -s "${TMPFILE}" ]
then
  console_log "Заполнил временный файл ${TMPFILE}"
  # clean_files
  cp $TMPFILE "${DB_BACKUP_PATH_TMP}$(date +'%Y-%m-%d %H:%M:%S').imported.sql"
  # mv $TMPFILE $DB_BACKUP_FILE
else
  console_log ERROR "Для импорта отправьте в данный скрипт файл, используя стандартный ввод, например:
    ssh site '...../.migrate/db_import.sh' < db.sql
  "
  console_log event $EVENT_NAME "\\e[1mFINISHED\\e[22m"
  exit 201
fi

MYSQL_ARGS="-h ${DB_CONFIG_HOST} -u ${DB_CONFIG_USER} -p${DB_CONFIG_PASSWORD}"

# проверить на наличие PV, чтобы отображать ход импорта
if (command -v pv >/dev/null 2>&1); then
  # console_log 'PV exist'
  MYSQL_IMPORT="pv -i 1 -p -t -e ${TMPFILE} | mysql ${MYSQL_ARGS} -D ${DB_CONFIG_DBASE}"
else
  MYSQL_IMPORT="mysql ${MYSQL_ARGS} -D ${DB_CONFIG_DBASE} < ${TMPFILE}"
fi


IMPORT=$(eval ${MYSQL_IMPORT} 2>/dev/null);
err_num=$?

if (( !$err_num && $H_CHECKOUT_CLEARCACHE )); then
  console_log "Запускаю очистку кеша сайта."
  result_cc=$(clear_cache)
  if [ -n "${result_cc}" ]; then
    console_log warn $result_cc
  else
    console_log ERROR "Не удалось очистить кеш, проверьте наличие метода clear_cache в провайдере: ${PROVIDER}"
  fi
fi

console_log --color=bg_green event $EVENT_NAME "\e[1mFINISHED\e[22m"

exit $err_num