#!/bin/bash

function clear_fields {

  for current_table in $@; do
    tmp_current_table=${DB_CONFIG_TABLE_PREFIX}${current_table}
    TMP_FILENAME=$DB_BACKUP_PATH_TMP"${tmp_current_table}.sql"
    console_log "Таблица: ${tmp_current_table}"
    # DB_TABLES_INCLUDE[$i]="${DB_CONFIG_TABLE_PREFIX}${arg}";
    # ((i += 1))
    # //////////////////////////////////////////////////////////////////////////////////////
    # получим запрос на создание таблицы и вырежем из него автоинкрементное поле
    # DUMP_TMP=$(eval "${MYSQL_DUMP} -d -t --quick ${DB_CONFIG_TABLE_PREFIX}user_attributes" | sed 's/ AUTO_INCREMENT=[0-9]*//g');
    DUMP_TMP=$(eval "${MYSQL_DUMP} -d -K --quick ${tmp_current_table} 2>&1 2>/dev/null" | sed 's/ AUTO_INCREMENT=[0-9]*//g');

    # удалим содержимое до фразы DROP TABLE
    DUMP_TMP=$(echo "$DUMP_TMP"  | sed -n '/DROP\sTABLE/,$p')

    # нужно ли удалять все между этими штуками???
    # /*!40101 SET character_set_client = utf8 */;
    DUMP_TMP=$(echo "$DUMP_TMP"  | sed '/\/\*\!.*\*\/;/d')

    echo "${DUMP_TMP}" | grep -vE \
    -e "--" \
    > $TMP_FILENAME;

    # поменяем права у файликов на всякий
    # chmod 0777 $DB_BACKUP_FILE
    # chmod 0777 $DB_BACKUP_PATH_TMP"${tmp_current_table}.sql"


    console_log "Записал изменения в: ${DB_BACKUP_PATH_TMP}${tmp_current_table}.sql"

    # если в конфиге есть переменная хранящая поля которые нужно сбросить, то:
    tmp_current_table_cf=$(eval echo $'${'`echo "DB_TABLES_DEFAULT_${current_table}[*]"`'}')
    tmp_current_table_cf=(`echo $tmp_current_table_cf | sed 's/\s/\n/g'`)
    # tmp_current_table_cf=$(eval $'${'`echo "DB_TABLES_DEFAULT_${current_table}"`'[@]}')

    # eval "$(echo "${ini[*]}")"   # eval the result
    # EVAL_STATUS=$?
    # console_log WARN "zxc=${EVAL_STATUS}"
    # tmp_current_table_cf=$(eval $'(${'`echo "DB_TABLES_DEFAULT_${current_table}"`'})')
    # tmp_current_table_cf=$(eval $'${'`echo "DB_TABLES_DEFAULT_${current_table}"`'[@]}')


    # console_log WARN "zxc=${tmp_current_table_cf[*]}"
    if [ -n "$tmp_current_table_cf" ]; then
      # console_log "Поля для очистки: ${tmp_current_table_cf[*]}"
      console_log "Поля для очистки: ${tmp_current_table_cf[@]}"

      # добавим в новый файл INSERT
      # получим данные из таблицы исключив не нужные поля
      # WITH_EXCLUDED_FIELDS=$(eval "$MYSQL_QUERY 'SELECT GROUP_CONCAT(COLUMN_NAME) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = \"${tmp_current_table}\" AND COLUMN_NAME NOT IN (\"$(join_by '\",\"' ${tmp_current_table_cf[@]})\")' 2>&1 2>/dev/null");
      WITH_EXCLUDED_FIELDS=$(eval "$MYSQL_QUERY 'SELECT GROUP_CONCAT(COLUMN_NAME) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = \"${tmp_current_table}\" AND COLUMN_NAME NOT IN (\"$(join_by '","' ${tmp_current_table_cf[@]})\")' 2>&1 2>/dev/null");
      console_log 'Список итоговых полей: '${WITH_EXCLUDED_FIELDS}
      SELECT_QUERY=$(eval "$MYSQL_QUERY 'SELECT ${WITH_EXCLUDED_FIELDS} FROM ${tmp_current_table};'"2>&1 2>/dev/null);
      # console_log 'SQL: '${SELECT_QUERY}

      INSERT_QUERY=$'\n'
      while IFS= read -r LINE
      do
        # $'\n' - это добавляет перенос строки в конец переменной
        INSERT_QUERY+='INSERT INTO `'${tmp_current_table}'` ('"${WITH_EXCLUDED_FIELDS}) VALUES ('"$(sed -e "s/\t/','/g" <<< $LINE)"');${NEW_LINE}"
        # echo "$LINE"
      done < <(printf '%s\n' "$SELECT_QUERY")
      # console_log 'INSERT_QUERY: '${INSERT_QUERY}

      # clear_fields ${DB_TABLES_DEFAULT[*]}
    fi

    # echo "LOCK TABLES \`${tmp_current_table}\` WRITE;${NEW_LINE}"\
    printf '%s\n' "LOCK TABLES \`${tmp_current_table}\` WRITE;"\
    "/*!40000 ALTER TABLE \`${tmp_current_table}\` DISABLE KEYS */;"\
    "${INSERT_QUERY}"\
    "/*!40000 ALTER TABLE \`${tmp_current_table}\` ENABLE KEYS */;"\
    "UNLOCK TABLES;" >> $TMP_FILENAME;

    # read -n 1 B

  done
  unset current_table
  unset tmp_current_table

  # return 1;
  # # склеим с основным файлом
  # echo $(cat $DB_BACKUP_PATH_TMP"user_attributes.sql" >> $DB_BACKUP_FILE);
  # console_log "Склеил user_attributes.sql с основным файлом"
  # //////////////////////////////////////////////////////////////////////////////////////
}


# function insert_tables {
  # вставка из DB_TABLES_CLEAR
# }
