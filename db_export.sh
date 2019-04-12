#!/bin/bash
# https://www.cyberciti.biz/faq/unix-linux-bash-script-check-if-variable-is-empty/
# http://qaru.site/questions/20275/how-to-define-hash-tables-in-bash
# Reliable way for a bash script to get the full path to itself?
# http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
pushd `dirname $0` > /dev/null
PATH_PWD=`pwd`
popd > /dev/null

EVENT_NAME="ModX DB export"
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
# подгржаем файл глобальных переменных
source $PATH_PWD/functions/parse_args.sh
source $PATH_PWD/functions/vars.sh
source $PATH_PWD/functions/files.sh


console_log -c=bg_yellow event $EVENT_NAME
# console_log event $EVENT_NAME
# console_log --pipe=1 err 'test pipe = 1'
# console_log --pipe=2 err 'test pipe = 2'
# console_log err "DB_BACKUP_FILE=$DB_BACKUP_FILE"
# console_log err "EXPORT_FILE=$EXPORT_FILE"
# die

if [[ -n ${DB_TABLES_REMOVE_INSERT} ]]; then
  # console_log "XXX=${DB_TABLES_REMOVE_INSERT}="
  DB_TABLES_REMOVE_INSERT="("$(sed -E 's/\s+/\|/g' <<< $DB_TABLES_REMOVE_INSERT)")"
  # console_log "DB_TABLES_REMOVE_INSERT=${DB_TABLES_REMOVE_INSERT}"
fi

# exit 1;

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
# exit 1;

# if [ -n ${DB_TABLES_REMOVE_INSERT} ]; then
#   DB_TABLES_REMOVE_INSERT="("$(sed -E 's/\s+/\|/g' <<< $DB_TABLES_REMOVE_INSERT)")"
#   console_log "DB_TABLES_REMOVE_INSERT=${DB_TABLES_REMOVE_INSERT}"
# fi

# очищаем директорию для хранения данных
clean_files
# if [ ! -d $DB_BACKUP_PATH ]
# then
#      mkdir $DB_BACKUP_PATH
# else
#      console_log "Result directory exists, clear it: ${DB_BACKUP_PATH}"
#      # echo rm -rf "${DB_BACKUP_PATH}*"
#      # rm -rf "${DB_BACKUP_PATH}*"
#      ############# rm -rf "$DB_BACKUP_PATH"/*
#      find "$DB_BACKUP_PATH" -mindepth 1 -delete
#      # rm -rf $DB_BACKUP_PATH/db.sql_2
# fi
# mkdir -p $DB_BACKUP_PATH_TMP

# exit 0;
# строка соединения
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

# отключем вывод ошибок
# TABLES=$(eval "$MYSQL_QUERY 'SHOW TABLES LIKE \"${DB_CONFIG_TABLE_PREFIX}%\";'"2>&1 2>/dev/null);

# выводим таблицы за исключением user_attributes
# DB_TABLES_INCLUDE=''


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

# if [[ -n "${DB_TABLES_CLEAR[*]}" ]]; then
#   # исключаем таблицы из экспорта которые должны быть добавлены, но импортированы
#   # в запрос будут другим способом

#   if [[ $DB_TABLES_AUTOPREFIX = 1 ]] && [[ -n "$DB_TABLES_AUTOPREFIX" ]]; then
#     # console_log 'Добавляю префиксы'
#     i=0
#     for arg in ${DB_TABLES_CLEAR[*]}; do
#       DB_TABLES_DEFAULT_WP[$i]="${DB_CONFIG_TABLE_PREFIX}${arg}";
#       ((i += 1))
#     done
#   fi
#   unset $arg
#   # TABLES_EXCLUDE=" AND \`Tables_in_${DB_CONFIG_DBASE}\` NOT IN (\"${DB_TABLES_DEFAULT_WP[*]}\")"
#   console_log WARN "Исключаю из экспорта таблицы без вставок ${DB_TABLES_DEFAULT_WP[@]}"
# fi

# DB_TABLES_EXCLUDE=("${DB_TABLES_EXCLUDE[@]}" "${DB_TABLES_DEFAULT_WP[@]}" "${DB_TABLES_DEFAULT_WP[@]}")
DB_TABLES_EXCLUDE=("${DB_TABLES_EXCLUDE[@]}" "${DB_TABLES_DEFAULT_WP[@]}")

if [[ -n "${TABLES_EXCLUDE[*]}" ]]; then
  # TABLES_EXCLUDE_STR=''
  # for TABLE_NAME in ${TABLES_EXCLUDE[*]}; do
  #   TABLES_EXCLUDE_STR+=" \"${TABLE_NAME}\" "
  # done
  # unset TABLE_NAME
  # TABLES_EXCLUDE=" AND \`Tables_in_${DB_CONFIG_DBASE}\` NOT IN (\"${TABLES_EXCLUDE[@]}\")"
  # TABLES_EXCLUDE=" AND \`Tables_in_${DB_CONFIG_DBASE}\` NOT IN ($TABLES_EXCLUDE_STR)"
  TABLES_EXCLUDE_STR=" AND \`Tables_in_${DB_CONFIG_DBASE}\` NOT IN (\"$(join_by '","' ${TABLES_EXCLUDE[@]})\")"
  # console_log WARN "Исключаю из экспорта таблицы ${TABLES_EXCLUDE[*]}"
  console_log WARN "Исключаю из экспорта таблицы: ${TABLES_EXCLUDE_STR}"
fi


if [[ -n "${DB_TABLES_INCLUDE[*]}" ]]; then
# if [ ! -z "${DB_TABLES_INCLUDE[*]}" ]; then
  if [[ $DB_TABLES_AUTOPREFIX = 1 ]] && [[ -n "$DB_TABLES_AUTOPREFIX" ]]; then
    # console_log 'Добавляю префиксы'
    i=0
    for arg in ${DB_TABLES_INCLUDE[*]}; do
      DB_TABLES_INCLUDE[$i]="${DB_CONFIG_TABLE_PREFIX}${arg}";
      ((i += 1))
    done
  fi
  # TABLES=${DB_TABLES_INCLUDE[*]}

  # TABLES_INCLUDE_STR=''
  # for TABLE_NAME in ${DB_TABLES_INCLUDE[*]}; do
    # TABLES_INCLUDE_STR+=" \"${TABLE_NAME}\" "
  # done
  # unset TABLE_NAME
  # TABLES_INCLUDE=" AND \`Tables_in_${DB_CONFIG_DBASE}\` NOT IN (\"${TABLES_INCLUDE[@]}\")"
  # TABLES_INCLUDE=" AND \`Tables_in_${DB_CONFIG_DBASE}\` IN ($TABLES_INCLUDE_STR)"
  TABLES_INCLUDE=" \`Tables_in_${DB_CONFIG_DBASE}\` IN (\"$(join_by '","' ${DB_TABLES_INCLUDE[@]})\")"

  console_log WARN "Включаю в экспорт таблицы: ${TABLES_INCLUDE[*]}"

  # console_log  err "Экспортирую таблицы ${DB_TABLES_INCLUDE[*]}"
# else
fi





TABLES_RESULT_LIST=''
# вычисляем пересечение массивов чтоб в запрос отправить список только нужных таблице
if [[ -n "${DB_TABLES_INCLUDE[*]}" ]] && [[ -n "${DB_TABLES_EXCLUDE[*]}" ]]; then
  intersections_tables=()
  for item1 in ${DB_TABLES_INCLUDE[@]}; do
    console_log warn $item1
    in_both=""
    for item2 in ${DB_TABLES_EXCLUDE[@]}; do
      [ "$item1" == "$item2" ] && in_both=Yes
    done
    if [[ ! -n "${in_both}" ]]; then
        intersections_tables+=( "$item1" )
    fi
  done
  TABLES_RESULT_LIST=" \`Tables_in_${DB_CONFIG_DBASE}\` IN (\"$(join_by '","' ${intersections_tables[@]})\")"
elif [[ -n "${DB_TABLES_EXCLUDE[*]}" ]]; then
  TABLES_RESULT_LIST=" \`Tables_in_${DB_CONFIG_DBASE}\` NOT IN (\"$(join_by '","' ${DB_TABLES_EXCLUDE[@]})\")"
elif [[ -n "${DB_TABLES_INCLUDE[*]}" ]]; then
  TABLES_RESULT_LIST=" \`Tables_in_${DB_CONFIG_DBASE}\` IN (\"$(join_by '","' ${DB_TABLES_INCLUDE[@]})\")"
fi

# printf '%s\n' "${intersections_tables[@]}"
# console_log "ZXC: "$TABLES_RESULT_LIST


# TABLES="$MYSQL_QUERY 'SHOW TABLES WHERE $TABLES_RESULT_LIST AND \`Tables_in_${DB_CONFIG_DBASE}\` LIKE \"${DB_CONFIG_TABLE_PREFIX}%\";'";
# TABLES="$MYSQL_QUERY 'SHOW TABLES WHERE ${TABLES_INCLUDE} ${TABLES_EXCLUDE} AND \`Tables_in_${DB_CONFIG_DBASE}\` LIKE \"${DB_CONFIG_TABLE_PREFIX}%\";'";
TABLES=$(eval "$MYSQL_QUERY 'SHOW TABLES WHERE ${TABLES_RESULT_LIST} AND \`Tables_in_${DB_CONFIG_DBASE}\` LIKE \"${DB_CONFIG_TABLE_PREFIX}%\";'"2>&1 2>/dev/null);
# TABLES=$(eval "$MYSQL_QUERY 'SHOW TABLES WHERE ${TABLES_INCLUDE} ${TABLES_EXCLUDE} AND \`Tables_in_${DB_CONFIG_DBASE}\` LIKE \"${DB_CONFIG_TABLE_PREFIX}%\";'"2>&1 2>/dev/null);
# TABLES=$(eval "$MYSQL_QUERY 'SHOW TABLES WHERE \`Tables_in_${DB_CONFIG_DBASE}\` NOT IN (\"${DB_CONFIG_TABLE_PREFIX}user_attributes\") AND \`Tables_in_${DB_CONFIG_DBASE}\` LIKE \"${DB_CONFIG_TABLE_PREFIX}%\";'"2>&1 2>/dev/null);

# TABLES=$(eval "$MYSQL_QUERY 'SHOW TABLES WHERE \"Tables_in_${DB_CONFIG_DBASE}\" NOT IN (\"${DB_CONFIG_TABLE_PREFIX}user_attributes\") AND \"Tables_in_${DB_CONFIG_DBASE}\" LIKE \"${DB_CONFIG_TABLE_PREFIX}%\";'"2>&1 2>/dev/null);
                      # echo  "$MYSQL_QUERY 'SHOW TABLES WHERE \"Tables_in_${DB_CONFIG_DBASE}\" NOT IN (\"${DB_CONFIG_TABLE_PREFIX}user_attributes\") AND \"Tables_in_${DB_CONFIG_DBASE}\" LIKE \"${DB_CONFIG_TABLE_PREFIX}%\";'" >&2;
                       # echo "SHOW TABLES LIKE \"${DB_CONFIG_TABLE_PREFIX}%\" WHERE \`Tables_in_${DB_CONFIG_DBASE}\` NOT LIKE \"%user_attributes\";";

# заменяем перенос строки
TABLES=$(sed 's/\\n/_/g' <<< $TABLES)
# console_log "ZXC=${TABLES}";
# exit 107;


# DUMP=$(eval "${MYSQL_DUMP} ${TABLES} > ${DB_BACKUP_PATH}db.sql");
# chmod 0777 $DB_BACKUP_FILE

# сохраним в переменную чтобы передать в grep
# DUMP=$(eval "${MYSQL_DUMP} ${TABLES} "2>&1 2>/dev/null);
# echo "${MYSQL_DUMP} ${TABLES}" > dump.query.txt
DUMP=$(eval "${MYSQL_DUMP} ${TABLES}" 2>/dev/null);
# DUMP=$(eval "${MYSQL_DUMP} --ignore-table=${DB_CONFIG_DBASE}.${DB_CONFIG_TABLE_PREFIX}user_attributes ");

# echo "XXX=${DUMP}">&2;
# echo "XXX="${MYSQL_DUMP} ${TABLES} >&2;

# удаялем лишние данные из sql
# https://stackoverflow.com/questions/11522276/remove-insert-data-of-a-specific-table-from-mysqldump-output-sed


# удаляем лишние данные, grep не может записывать данные в текущий файл
# grep -v -e "^-- Dump completed" <<< $DUMP > $DB_BACKUP_FILE;
# cat "${DB_BACKUP_PATH}db.sql" | grep -v -e "^-- Dump completed" > $DB_BACKUP_FILE;
# grep -v -e "^-- Dump completed" $DB_BACKUP_FILE > $DB_BACKUP_FILE"_2";
# CLI: проверка выполнения вырезания из строки
# ./backup.sh && ls -ls ./db_backup/ && cat db_backup/db.sql_3 | grep --color=always -P "Dump completed" | cut -c 1-50



# sed -E "s#^INSERT INTO \`${DB_CONFIG_TABLE_PREFIX}media_sources.*##" $DB_BACKUP_FILE > $DB_BACKUP_FILE"_DEL"

# комментируем insert пока хреново работает коментит до конца файла вместо блока
# DUMP=$(sed '/-- Dumping data for table `zOpa0k_media_sources`/,/-- Table structure for table/ {/^--/! s/^/--/}' <<< $DUMP)
# DUMP=$(sed -e '/-- Dumping data for table `zOpa0k_media_sources`/,/-- Table structure for table/ {/^--/! s/^/--/}' $DB_BACKUP_FILE > $DB_BACKUP_FILE"31")
# /-- Dumping data for table `${DB_CONFIG_TABLE_PREFIX}(manager_log|session)`/,/-- Table structure for table/ {
# sed -e '
#     /^-- Dumping data for table `'"${DB_CONFIG_TABLE_PREFIX}"'session`/,/^-- Table structure for table/ {
#         /^--/! s/^/--/
#     }
# ' $DB_BACKUP_FILE"_2" > $DB_BACKUP_FILE"_3"

# CLI: проверка выполнения вырезания из строки
# ./backup.sh && ls -ls ./db_backup/ && cat db_backup/db.sql_2 | grep --color=always -P "zOpa0k_manager_log|zOpa0k_session" | cut -c 1-50

# XZ=$(ls -ls ./db_backup/ && cat db_backup/db.sql | grep --color=always -P "${DB_CONFIG_TABLE_PREFIX}${DB_TABLES_REMOVE_INSERT}" | cut -c 1-70)
# ls -ls ./db_backup/ && cat db_backup/db.sql | grep --color=always -P "${DB_CONFIG_TABLE_PREFIX}${DB_TABLES_REMOVE_INSERT}" | cut -c 1-70;
# XZ=$(eval "ls -ls ./db_backup/ && cat db_backup/db.sql | grep --color=always -P '${DB_CONFIG_TABLE_PREFIX}${DB_TABLES_REMOVE_INSERT}' | cut -c 1-70")

if [[ -n "${DB_TABLES_REMOVE_INSERT}" ]]; then
  # -e "-- Dump completed" \
  # /////////////////////////////////////// проблема в этом!!!
  # echo "${DUMP}" | grep -vE \
  # -e "--" оставляет все строки кроме тех что начинаются с --
  printf '%s\n' "${DUMP}" | grep -vE \
    -e "^--" \
    -e "^INSERT INTO \`${DB_CONFIG_TABLE_PREFIX}${DB_TABLES_REMOVE_INSERT}\`" > $DB_BACKUP_FILE;
  # ///////////////////////////////////////

  # echo "${DUMP}" > $DB_BACKUP_FILE;
  # chmod 0777 $DB_BACKUP_FILE

  console_log "Удалил лишние данные из запроса и произвел запись в: ${DB_BACKUP_FILE}"

  TEST=$(ls -lARGh $DB_BACKUP_PATH && cat ${DB_BACKUP_FILE} | grep --color=always -P "${DB_CONFIG_TABLE_PREFIX}${DB_TABLES_REMOVE_INSERT}" | cut -c 1-70)
  # TEST=$(grep -rl "${DB_BACKUP_PATH}" && cat ${DB_BACKUP_FILE} | grep --color=always -P "${DB_CONFIG_TABLE_PREFIX}${DB_TABLES_REMOVE_INSERT}" | cut -c 1-70)
  # TEST=$(grep -rl db_backup/ && cat db_backup/db.sql | grep --color=always -P "SImLuCK1_" | cut -c 1-70)
  console_log "Проверка результата: ${TEST}"
else
  # -e "^--" оставляет все строки кроме тех что начинаются с --
  printf '%s\n' "${DUMP}" | grep -vE \
    -e "^--" > $DB_BACKUP_FILE;
fi


# необходимо удалить динамические бесполезные данные которые могут попасть в коммит
# например таблица user_attributes содержит данные о послед входе пользователя, они не нужны
# zOpa0k_user_attributes
# STATS_TABLES=$(mysql -h $HOST -u $USER -p$PASSWORD -D $DATABASE -Bse "SHOW TABLES LIKE 'modx_%';")

# XXX=$(eval "$MYSQL_QUERY 'SELECT *, 0 AS logincount, 0 AS lastlogin, 0 AS thislogin, '' as sessionid FROM ${DB_CONFIG_TABLE_PREFIX}user_attributes;'");
# XXX=$(eval "$MYSQL_QUERY 'SELECT *, 0 AS logincount, 0 AS lastlogin, 0 AS thislogin FROM ${DB_CONFIG_TABLE_PREFIX}user_attributes;'");
# XXX=$(eval "$MYSQL_QUERY 'SELECT *, 0 AS logincount, 0 AS lastlogin, 0 AS thislogin FROM ${DB_CONFIG_TABLE_PREFIX}user_attributes;'");
# SELECT table_name,column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'employee' AND TABLE_SCHEMA = 'test'

# именно в этом месте чтобы подхватить глобальные переменные
source $PATH_PWD/functions/db.sh

# if [ -n "${DB_TABLES_CLEAR[*]}" ]; then
#   console_log WARN "Добавляю таблицы без INSERT ${DB_TABLES_CLEAR[*]}"
#   insert_tables ${DB_TABLES_CLEAR[*]}
# fi

if [[ -n "${DB_TABLES_DEFAULT[*]}" ]]; then
  console_log WARN "Очищаю таблицы очистки ${DB_TABLES_DEFAULT[*]}"
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
fi



# rm -rf "${DB_BACKUP_PATH_TMP}"/tmp/
find "${DB_BACKUP_PATH_TMP}" -mindepth 1 -delete
console_log warn "Удалил временную папку: ${DB_BACKUP_PATH_TMP}"

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

# while read line ; do
#     echo "ZXC=${line}"
# done < <(echo ${SELECT_QUERY})

# INSERT INTO `members` (`full_names`,`gender`,`physical_address`,`contact_number`) VALUES ('Leonard Hofstadter','Male','Woodcrest',0845738767);

# echo ${SELECT_QUERY} | awk '{print "theme: " $1  " guid: " $3}'

# ${SELECT_QUERY} while IFS=$'\t' read theme_name guid; do echo "theme: $theme_name guid: $guid"; done




# echo ${DUMP_USER_ATTR}

# SELECT GROUP_CONCAT(COLUMN_NAME) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zOpa0k_user_attributes' AND COLUMN_NAME NOT IN ('logincount','lastlogin','thislogin')

# SET @SQL = CONCAT('SELECT ', (SELECT GROUP_CONCAT(COLUMN_NAME) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zOpa0k_user_attributes' AND COLUMN_NAME NOT IN ('logincount','lastlogin','thislogin')), ' FROM zOpa0k_user_attributes');PREPARE stmt1 FROM @SQL;EXECUTE stmt1;

# >mysql ... -BNr -e "SELECT 'funny man', 'wonderful' UNION SELECT 'no_space', 'I love spaces';" | while IFS=$'\t' read theme_name guid; do echo "theme: $theme_name guid: $guid"; done
# theme: funny man guid: wonderful
# theme: no_space guid: I love spaces

# echo ''>&2
console_log -c=bg_yellow event $EVENT_NAME "FINISHED"
# console_log ERROR $EVENT_NAME;
# console_log event $EVENT_NAME "FINISHED"
