#!/bin/bash
# http://qaru.site/questions/20275/how-to-define-hash-tables-in-bash
# Reliable way for a bash script to get the full path to itself?
# http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
pushd `dirname $0` > /dev/null
PATH_PWD=`pwd`
popd > /dev/null

EVENT_NAME="DB MIGRATE EXPORT"
source $PATH_PWD/functions/bash-ini-parser/bash-ini-parser
source $PATH_PWD/functions/common.sh
# получаем переменные из ini
cfg_parser $PATH_PWD/config.ini
# исправим не правильно сформированный ini файл (не обязательно)
# cfg_writer
cfg_section_common
# импортируем секцию develop из ini файла
cfg_section_develop

source $PATH_PWD/functions/parse_args.sh
source $PATH_PWD/functions/vars.sh
source $PATH_PWD/functions/files.sh
# source $PATH_PWD/functions/modx.sh
# source $PATH_PWD/functions/db.sh

# console_log warn "---------========DB MIGRATE EXPORT========---------";
console_log event $EVENT_NAME

# если перенаправлять поток напрямую в файл, то памяти будет
# тогда нужно перенапрвлять его во врменный файл, а этот файл затем переносить

# RESULTS=$(eval "${CLI_DB_EXPORT} 1> ${DB_BACKUP_FILE}")
# RESULTS=$(eval "${CLI_DB_EXPORT} 1> 1.sql")
# RESULTS=$(eval "${CLI_DB_EXPORT} &> x.txt")

# TMPFILE=".${0##*/}-$$" && touch "$TMPFILE";
# TMPDIR=".${0##*/}-$$" && mkdir -v "$TMPDIR"

# RESULTS=$(eval "${CLI_DB_EXPORT} 1> ${EXPORT_FILE}")
TMPFILE=$(mktemp);
console_log WARN "Создал временный файл: ${TMPFILE}"
RESULTS=$(eval "${CLI_DB_EXPORT} --output 1> ${TMPFILE}")
# RESULTS=$(eval "${CLI_DB_EXPORT}")
err_num=$?
# if [ -n $err_num ]; then
if (($err_num)); then
  console_log ERROR "[${err_num}] Возникла ошибка не могу создать файл БД!"
  console_log event $EVENT_NAME "\e[1mFINISHED\e[22m"
  cat $TMPFILE;
  # echo $RESULTS
  exit $err_num;
else
  clean_files
  mv $TMPFILE $DB_BACKUP_FILE
  # echo $RESULTS > $DB_BACKUP_FILE
fi


console_log event $EVENT_NAME "\e[1mFINISHED\e[22m"
# echo $RESULTS
echo $DB_BACKUP_FILE;
exit 0;
