#!/bin/bash
NEW_LINE=$'\n';
[[ ! -n $DB_BACKUP_PATH ]] && DB_BACKUP_PATH="${PATH_PWD}/backups/"
[[ ! -n $DB_BACKUP_PATH_TMP ]] && DB_BACKUP_PATH_TMP="${DB_BACKUP_PATH}tmp/"
[[ ! -n $DB_BACKUP_FILE ]] && DB_BACKUP_FILE="${DB_BACKUP_PATH}${EXPORT_FILE}"
