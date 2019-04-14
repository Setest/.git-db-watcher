#!/bin/bash

console_log "Running script $0"

display_usage() {
  console_log "Help for: $0"
  # console_log $(echo -e $(cat "${0}.txt"))

  if [[ ! -r "${0}.txt" ]]
    then
      console_log ERROR "Файл помощи '${PATH_PWD}/${0}.txt' не существует"
      # exit 100;
    else
      # while IFS= read -r line; do
      # while read -t 1 -r line; do
      # done < "${0}.txt"

      # for line in `cat ${0}.txt`;do
      #   console_log "$line"
      # done

      while IFS= read -r line; do
        console_log "$line"
      done < <(grep "" ${0}.txt)

  fi

}

# console_log warn "обрабатываю: $#"
while (( "$#" )); do
  # console_log warn "обрабатываю: ${1}"
  case "$1" in
    -h|--help)
      display_usage
      die
    ;;
    -o|--output)
      CONFIG[output]=1;
      # console_log warn "zzz \"${CONFIG[@]}\""
    ;;
    -c=*|--config=*)
    # загружаем конфиг
      CONFIG_PART=`echo $1 | sed 's/[-a-zA-Z0-9]*=//'`
      console_log warn "загружаю раздел \"${CONFIG_PART}\" из config.ini"
      # $(eval "cfg_section_${CONFIG_PART}")
      cfg_section_${CONFIG_PART}
      # cfg_section_site1
    ;;
    # -*|--*=) # unsupported flag
    #   console_log error "Нет такого параметра: ${1}"
    #   ;;
    --) # end argument parsing
      break
      ;;
    *)# параметры которые перегружают переменные скрипта

      # если строка содержит знак = (равенство)
      # https://stackoverflow.com/a/52671757/9998651
      if [[ "${1,,}" == *"="* ]]; then
        PROP_NAME=`echo $1 | sed -E 's/(=.*)//'`
        PROP_VALUE=`echo $1 | sed -E 's/[-a-zA-Z0-9_]*=//'`
      else
        PROP_NAME=$1
      fi
      console_log "перегружаю переменную: ${1}"
      # $(eval echo $'${'`echo "${PROP_NAME}=${PROP_VALUE}"`'}')
      # console_log "result ${PROP_NAME}=${PROP_VALUE}"
      eval "$(echo "${PROP_NAME}=${PROP_VALUE}")"   # eval the result
      ;;
  esac
  shift
done

# set positional arguments in their proper place
eval set -- "$PARAMS"
