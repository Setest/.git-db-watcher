#!/bin/bash

pushd `dirname $0` > /dev/null
PATH_PWD=`pwd`
popd > /dev/null

EVENT_NAME="DB MIGRATE EXPORT"
source $PATH_PWD/functions/common.sh
include $PATH_PWD/functions/files.sh
check_config

include $PATH_PWD/functions/bash-ini-parser/bash-ini-parser
# получаем переменные из ini
cfg_parser $PATH_PWD/config.ini
cfg_section_common
cfg_section_develop

include $PATH_PWD/functions/parse_args.sh
include $PATH_PWD/functions/vars.sh

console_log event $EVENT_NAME

# если перенаправлять поток напрямую в файл, то памяти будет
# тогда нужно перенапрвлять его во врменный файл, а этот файл затем переносить

TMPFILE=$(mktemp);
console_log WARN "Создал временный файл: ${TMPFILE}"
RESULTS=$(eval "${CLI_DB_EXPORT} --output 1> ${TMPFILE}")
err_num=$?

if (($err_num)); then
  console_log ERROR "[${err_num}] Возникла ошибка не могу создать файл БД!"
  console_log event $EVENT_NAME "\e[1mFINISHED\e[22m"
  cat $TMPFILE;
  exit $err_num;
else
  clean_files
  mv $TMPFILE $DB_BACKUP_FILE
fi


console_log event $EVENT_NAME "\e[1mFINISHED\e[22m"
echo $DB_BACKUP_FILE;
exit 0;
