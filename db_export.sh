#!/bin/bash

pushd `dirname $0` > /dev/null
PATH_PWD=`pwd`
popd > /dev/null

EVENT_NAME="ModX DB export"
declare -A CONFIG

source $PATH_PWD/functions/common.sh
include $PATH_PWD/functions/bash-ini-parser/bash-ini-parser

cfg_parser $PATH_PWD/config.ini
# исправим не правильно сформированный ini файл (не обязательно)
# cfg_writer
# импортируем секции из ini
cfg_section_common
cfg_section_server
# подгржаем файл глобальных переменных
include $PATH_PWD/functions/parse_args.sh $@
# source $PATH_PWD/functions/parse_args.sh
include $PATH_PWD/functions/vars.sh
include $PATH_PWD/functions/files.sh

console_log -c=bg_yellow event $EVENT_NAME

if [[ -n ${DB_TABLES_REMOVE_INSERT} ]]; then
  DB_TABLES_REMOVE_INSERT="("$(sed -E 's/\s+/\|/g' <<< $DB_TABLES_REMOVE_INSERT)")"
fi


get_provider

console_log "Database is ${DB_CONFIG_HOST}:${DB_CONFIG_DBASE}"

get_host

# очищаем директорию для хранения данных
clean_files

# переменные соединения с БД
# CONNECT="mysql -h ${DB_CONFIG_HOST} -u ${DB_CONFIG_USER} -p${DB_CONFIG_PASSWORD} -D ${DB_CONFIG_DBASE} -Bse"
MYSQL_ARGS="-h ${DB_CONFIG_HOST} -u ${DB_CONFIG_USER} -p${DB_CONFIG_PASSWORD}"
MYSQL_QUERY="mysql ${MYSQL_ARGS} -D ${DB_CONFIG_DBASE} -Bse"
# MYSQL_DUMP="mysqldump ${MYSQL_ARGS} -c -t -q ${DB_CONFIG_DBASE}"
# MYSQL_DUMP="mysqldump ${MYSQL_ARGS} --complete-insert --compact ${DB_CONFIG_DBASE}"
# MYSQL_DUMP="mysqldump ${MYSQL_ARGS} --opt --extended-insert=FALSE ${DB_CONFIG_DBASE}"
# MYSQL_DUMP="mysqldump ${MYSQL_ARGS} --extended-insert --skip-comments --ignore-table=${DB_CONFIG_DBASE}.${DB_CONFIG_TABLE_PREFIX}user_attributes ${DB_CONFIG_DBASE}"
# MYSQL_DUMP="mysqldump ${MYSQL_ARGS} --extended-insert --skip-comments --ignore-table=${DB_CONFIG_DBASE}.${DB_CONFIG_TABLE_PREFIX}user_attributes ${DB_CONFIG_DBASE}"
# MYSQL_DUMP="mysqldump ${MYSQL_ARGS} --complete-insert ${DB_CONFIG_DBASE}"
MYSQL_DUMP="mysqldump ${MYSQL_ARGS} --opt --skip-extended-insert ${DB_CONFIG_DBASE}"


TABLES_EXCLUDE=''
if [[ -n "${DB_TABLES_EXCLUDE[*]}" ]]; then
  # console_log ZZZ
  # exit 1;
  # исключаем таблицы из экспорта

  if [[ $DB_TABLES_AUTOPREFIX = 1 ]] && [[ -n "$DB_TABLES_AUTOPREFIX" ]]; then
    # console_log 'Добавляю префиксы'
    i=0
    for arg in ${DB_TABLES_EXCLUDE[*]}; do
      DB_TABLES_EXCLUDE[$i]="${DB_CONFIG_TABLE_PREFIX}${arg}";
      ((i += 1))
    done
  fi
  # TABLES_EXCLUDE=" AND \`Tables_in_${DB_CONFIG_DBASE}\` NOT IN (\"${DB_TABLES_EXCLUDE[*]}\")"
  console_log WARN "Исключаю из экспорта таблицы ${DB_TABLES_EXCLUDE[@]}"
fi


if [[ -n "${DB_TABLES_DEFAULT[*]}" ]]; then
  console_log  err "Список таблиц в записях которых будут сброшенны поля на значения по умолчанию: ${DB_TABLES_DEFAULT[*]}"
  # исключаем таблицы из экспорта которые должны быть добавлены, но импортированы
  # в запрос будут другим способом

  if [[ $DB_TABLES_AUTOPREFIX = 1 ]] && [[ -n "$DB_TABLES_AUTOPREFIX" ]]; then
    # console_log 'Добавляю префиксы'
    i=0
    for arg in ${DB_TABLES_DEFAULT[*]}; do
      DB_TABLES_DEFAULT_WP[$i]="${DB_CONFIG_TABLE_PREFIX}${arg}";
      ((i += 1))
    done
  fi
  unset $arg
  # TABLES_EXCLUDE=" AND \`Tables_in_${DB_CONFIG_DBASE}\` NOT IN (\"${DB_TABLES_DEFAULT_WP[*]}\")"
  console_log WARN "Исключаю из экспорта таблицы очистки ${DB_TABLES_DEFAULT_WP[@]}"
fi

DB_TABLES_EXCLUDE=("${DB_TABLES_EXCLUDE[@]}" "${DB_TABLES_DEFAULT_WP[@]}")

if [[ -n "${TABLES_EXCLUDE[*]}" ]]; then
  TABLES_EXCLUDE_STR=" AND \`Tables_in_${DB_CONFIG_DBASE}\` NOT IN (\"$(join_by '","' ${TABLES_EXCLUDE[@]})\")"
  console_log WARN "Исключаю из экспорта таблицы: ${TABLES_EXCLUDE_STR}"
fi


if [[ -n "${DB_TABLES_INCLUDE[*]}" ]]; then
  if [[ $DB_TABLES_AUTOPREFIX = 1 ]] && [[ -n "$DB_TABLES_AUTOPREFIX" ]]; then
    i=0
    for arg in ${DB_TABLES_INCLUDE[*]}; do
      DB_TABLES_INCLUDE[$i]="${DB_CONFIG_TABLE_PREFIX}${arg}";
      ((i += 1))
    done
  fi
  TABLES_INCLUDE=" \`Tables_in_${DB_CONFIG_DBASE}\` IN (\"$(join_by '","' ${DB_TABLES_INCLUDE[@]})\")"
  console_log WARN "Включаю в экспорт таблицы: ${TABLES_INCLUDE[*]}"
fi


TABLES_RESULT_LIST=''
NO_TABLES=0
# вычисляем пересечение массивов чтоб в запрос отправить список только нужных таблице
if [[ -n "${DB_TABLES_INCLUDE[*]}" ]] && [[ -n "${DB_TABLES_EXCLUDE[*]}" ]]; then
  intersections_tables=()
  for item1 in ${DB_TABLES_INCLUDE[@]}; do
    # console_log warn $item1
    in_both=""
    for item2 in ${DB_TABLES_EXCLUDE[@]}; do
      [ "$item1" == "$item2" ] && in_both=Yes
    done
    if [[ ! -n "${in_both}" ]]; then
        intersections_tables+=( "$item1" )
    fi
  done
  if [[ -n "${intersections_tables[*]}" ]];then
    # console_log "okkkk"
    TABLES_RESULT_LIST=" \`Tables_in_${DB_CONFIG_DBASE}\` IN (\"$(join_by '","' ${intersections_tables[@]})\")"
  else
    NO_TABLES=1
    # console_log "faaaalse"
  fi
elif [[ -n "${DB_TABLES_EXCLUDE[*]}" ]]; then
  TABLES_RESULT_LIST=" \`Tables_in_${DB_CONFIG_DBASE}\` NOT IN (\"$(join_by '","' ${DB_TABLES_EXCLUDE[@]})\")"
elif [[ -n "${DB_TABLES_INCLUDE[*]}" ]]; then
  TABLES_RESULT_LIST=" \`Tables_in_${DB_CONFIG_DBASE}\` IN (\"$(join_by '","' ${DB_TABLES_INCLUDE[@]})\")"
fi


if (( ! $NO_TABLES )); then
  TABLES=$(eval "$MYSQL_QUERY 'SHOW TABLES WHERE ${TABLES_RESULT_LIST} AND \`Tables_in_${DB_CONFIG_DBASE}\` LIKE \"${DB_CONFIG_TABLE_PREFIX}%\";'"2>&1 2>/dev/null);
  # console_log "$MYSQL_QUERY 'SHOW TABLES WHERE ${TABLES_RESULT_LIST} AND \`Tables_in_${DB_CONFIG_DBASE}\` LIKE \"${DB_CONFIG_TABLE_PREFIX}%\";'";

  # заменяем перенос строки
  TABLES=$(sed 's/\\n/_/g' <<< $TABLES)
  $([[ -n "${TABLES}" ]] && console_log WARN "Dump tables: ${TABLES}" || console_log warn "Dump EVERY tables")
  # if [[ -n "${TABLES}" ]];then console_log "Dump tables: ${TABLES}"; else console_log warn "Dump EVERY tables"; fi

  DUMP=$(eval "${MYSQL_DUMP} ${TABLES}" 2>/dev/null);

  if [[ -n "${DB_TABLES_REMOVE_INSERT}" ]]; then
    # -e "^--" оставляет все строки кроме тех что начинаются с --
    printf '%s\n' "${DUMP}" | grep -vE \
      -e "^INSERT INTO \`${DB_CONFIG_TABLE_PREFIX}${DB_TABLES_REMOVE_INSERT}\`" > $DB_BACKUP_FILE;

    console_log "Удалил лишние данные из запроса и произвел запись в: ${DB_BACKUP_FILE}"

    TEST=$(ls -lARGh $DB_BACKUP_PATH && cat ${DB_BACKUP_FILE} | grep --color=always -P "${DB_CONFIG_TABLE_PREFIX}${DB_TABLES_REMOVE_INSERT}" | cut -c 1-70)
    console_log "Проверка результата: ${TEST}"
  # else
    # -e "^--" оставляет все строки кроме тех что начинаются с --
  fi

  printf '%s\n' "${DUMP}" | grep -vE \
    -e "^--" > $DB_BACKUP_FILE;

else
  console_log "Tables not set, create empty file: ${DB_BACKUP_FILE}"
  touch $DB_BACKUP_FILE;
fi
# exit 1;


# именно в этом месте чтобы подхватить глобальные переменные
include $PATH_PWD/functions/db.sh

if [[ -n "${DB_TABLES_DEFAULT[*]}" ]]; then
  console_log WARN "Очищаю таблицы очистки: ${DB_TABLES_DEFAULT[@]}"
  # console_log 'Очищаю поля у таблиц'
  clear_fields ${DB_TABLES_DEFAULT[*]}
fi


if [[ -n "${DB_BACKUP_PATH_TMP}" ]]; then
  find ${DB_BACKUP_PATH_TMP} -type f -name "*.sql" -print0 | while read -d $'\0' file
  do
    # склеим все временные файлы с основным файлом
    # echo $(cat $f >> $DB_BACKUP_FILE);
    cat $file >> $DB_BACKUP_FILE;
    console_log "Склеил ${file} с основным файлом"
  done

  find "${DB_BACKUP_PATH_TMP}" -mindepth 1 -type f -name "*.sql" -delete
  console_log warn "Удалил содержимое временной папки: ${DB_BACKUP_PATH_TMP}"
fi



if [[ -n "${CONFIG[output]}" ]]; then
  # DB_BACKUP_FILE="$PATH_PWD/null.txt"
  # console_log err "==${CONFIG[output]}=={$DB_BACKUP_FILE}=="
  # не забываем это отправляется в стандартный вывод
  # а на экране мы видим только вывод ошибок

  [ ! -f "$DB_BACKUP_FILE" ] && {
    console_log ERROR "$DB_BACKUP_FILE file not found.";
    console_log -c=bg_yellow event $EVENT_NAME "\e[1mFINISHED\e[22m"
    exit 101;
  }

  if [ -s "$DB_BACKUP_FILE" ]
  then
    cat $DB_BACKUP_FILE
    console_log "Отправил содержимое файла на стандартный вывод"
  else
    console_log -c='bg_red' "Файл выгрузки пустой!!!"
  fi

fi

console_log -c=bg_yellow event $EVENT_NAME "FINISHED"