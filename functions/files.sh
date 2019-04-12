#!/bin/bash

function clean_files {
  # console_log "xx: ${DB_BACKUP_PATH}"
  if [ ! -d $DB_BACKUP_PATH ]
  then
       console_log "Result directory not exists, create it: ${DB_BACKUP_PATH}"
       mkdir $DB_BACKUP_PATH
  else
    console_log WARN "Выполняю очистку: ${DB_BACKUP_PATH}"
    # console_log "Result directory exists, clear it: ${DB_BACKUP_PATH}"
    ############# rm -rf "$DB_BACKUP_PATH"/*
    # find ... -delete -printf 'rm %p\n'.
    find "$DB_BACKUP_PATH" -mindepth 1 -delete > /dev/null
    # find "$DB_BACKUP_PATH" -mindepth 1
  fi
  mkdir -p $DB_BACKUP_PATH_TMP
}
