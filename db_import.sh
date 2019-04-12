#!/bin/bash
# https://www.cyberciti.biz/faq/unix-linux-bash-script-check-if-variable-is-empty/
# http://qaru.site/questions/20275/how-to-define-hash-tables-in-bash
# Reliable way for a bash script to get the full path to itself?
# http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
pushd `dirname $0` > /dev/null
PATH_PWD=`pwd`
popd > /dev/null

EVENT_NAME="db_import"
declare -A CONFIG


source $PATH_PWD/functions/bash-ini-parser/bash-ini-parser
source $PATH_PWD/functions/common.sh
# source $PATH_PWD/functions/modx.sh
# source $PATH_PWD/functions/db.sh

cfg_parser $PATH_PWD/config.ini
# исправим не правильно сформированный ini файл (не обязательно)
# cfg_writer
# импортируем секцию develop из ini файла
cfg_section_common
# cfg_section_develop
cfg_section_server
cfg_section_hooks
# подгржаем файл глобальных переменных
source $PATH_PWD/functions/parse_args.sh
source $PATH_PWD/functions/vars.sh
source $PATH_PWD/functions/files.sh


console_log --color=bg_green event $EVENT_NAME
# console_log --pipe=1 err 'test pipe = 1'
# console_log --pipe=2 err 'test pipe = 2'
# console_log err "DB_BACKUP_FILE=$DB_BACKUP_FILE"
# console_log err "EXPORT_FILE=$EXPORT_FILE"
# die


# console_log "DB_CLEAR_TS="$DB_CLEAR_TS;
# console_log "DB_CLEAR_FS_user_attributes[1] value is \"${DB_CLEAR_FS_user_attributes[1]}"\"
# console_log "DB_CLEAR_FS_user_attributes[*] value is \"${DB_CLEAR_FS_user_attributes[*]}"\"

# for arg in ${DB_CLEAR_FS_user_attributes[*]}; do
#   console_log "field: "$arg
# done

get_provider

console_log "Database is ${DB_CONFIG_HOST}:${DB_CONFIG_DBASE}"
# exit 105;

declare -A MODX_CONFIG
# source $PATH_PWD/functions/modx.sh
# console_log "MODX_CONFIG: ${DB_CONFIG_HOST}"

# echo 'return_val: '$return_val;
# echo 'config: '$MODX_CONFIG;
# MYSQL_ARGS="-h ${DB_CONFIG_HOST} -u ${DB_CONFIG_USER} -p${DB_CONFIG_PASSWORD}"
# echo "${MYSQL_ARGS}"
# https://www.cyberciti.biz/faq/unix-linux-bash-script-check-if-variable-is-empty/
get_host

# console_log WARN "Всего аргументов ${#}"

# if ((!$#)); then
# if [ -z /dev/stdin ]; then
# if read -t 0; then
# if grep .; then

# if [[ -p /dev/stdin ]]
# then
#     console_log "stdin is coming from a pipe"
# fi
# if [[ -t 0 ]]
# then
#     console_log "stdin is coming from the terminal"
# fi
# if [[ ! -t 0 && ! -p /dev/stdin ]]
# then
#     console_log "stdin is redirected"
# fi

# if [ -p /dev/stdin ]; then
#   # без аргументов, завершаем работу
#   console_log ERROR "Для импорта отправьте в данный скрипт файл, используя стандартный ввод, например:
#     ssh site '...../.migrate/db_import.sh' < db.sql
#   "
#   console_log event $EVENT_NAME "\e[1mFINISHED\e[22m"
# fi

# touch ${DB_BACKUP_FILE}.txt

# FLAG=0
TMPFILE=$(mktemp);
# DB_BACKUP_FILE+='.tmp.sql'

# while read -t 0.01 -r -d '' LINE; do
# while read -r LINE; do
# while read -t 1 -r LINE; do
  # printf '%q\n' "${LINE}" >> ${TMPFILE}
  # printf '%s\n' "${LINE}" >> ${TMPFILE}
# done < /dev/stdin

while IFS= read -t 1 -r LINE; do
  printf '%s\n' "${LINE}" >> ${TMPFILE}
done < <(grep "" /dev/stdin)


if [ -s "${TMPFILE}" ]
then
  console_log "Заполнил временный файл ${TMPFILE}"
  # clean_files
  cp $TMPFILE "${DB_BACKUP_PATH_TMP}$(date +'%Y-%m-%d %H:%M:%S').imported.sql"
  # mv $TMPFILE $DB_BACKUP_FILE
  # console_log warn "Переместил полученные данные в ${DB_BACKUP_FILE}"
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
# if (( $H_CHECKOUT_CLEARCACHE )); then
  console_log "Запускаю очистку кеша сайта."
  result_cc=$(clear_cache)
  if [ -n "${result_cc}" ]; then
    console_log warn $result_cc
  else
    console_log ERROR "Не удалось очистить кеш, проверьте наличие метода clear_cache в провайдере: ${PROVIDER}"
  fi
fi

# console_log --color=red $EVENT_NAME "\e[1mFINISHED\e[22m"
# console_log --color=green $EVENT_NAME "\e[1mFINISHED\e[22m"
console_log --color=bg_green event $EVENT_NAME "\e[1mFINISHED\e[22m"

exit $err_num