#!/bin/bash

# на всякий включаем globstar чтобы можно было использовать констуркции вида:
# for i in **/*.txt; do
shopt -s globstar

# вывод сообщений в консоль с окраской в зависимости
# от переданного первого аргумента (например E или ERROR)
# все остальные аргументы считаются информацией для вывода
# если аргумент один то он выводится как сообщение со статусом по умолчанию.
function console_log {
  local new_line=$'\n';
  local color=''
  local msg=''
  local pipe=2
  local status=''
  local stddirection=''
  local postfix="$( echo -e "\e[0m" )"
  # echo '['$(date +'%a %Y-%m-%d %H:%M:%S %z')']' $1

  if ((!$#))
    then
      # без аргументов, завершаем работу
      return
    else

      # выбор канала стандартного вывода
      # # echo '1='$1>&2
      # case "$1" in
      #   -p=*|--pipe=*)
      #       if [[ "${1,,}" == *"="* ]]; then
      #         pipe=`echo $1 | sed -E 's/(.*=)//'`
      #         # echo 'set pipe='$pipe>&2
      #       fi
      #       shift
      #     ;;
      # esac

      for var in "$@"; do
      # while (( "$#" )); do
        case "$1" in
          -p=*|--pipe=*)
            if [[ "${1,,}" == *"="* ]]; then
              pipe=`echo $1 | sed -E 's/(.*=)//'`
              # echo 'set pipe='$pipe>&2
            fi
            shift
          ;;
          -c=*|--color=*)
            if [[ "${1,,}"==*"="* ]]; then
              color=`echo $1 | sed -E 's/(.*=)//'`
              case "$color" in
                red*)
                  color="$( echo -e "\e[1;49;31m" )"
                  # printf "%s" "color is red" >&${pipe};
                ;;
                green*)
                  color="$( echo -e "\e[0;49;92m" )"
                ;;
                bg_green*)
                  color="$( echo -e "\e[7;49;92m" )"
                ;;
                bg_red*)
                  color="$( echo -e "\e[7;49;91m" )"
                ;;
                bg_yellow*)
                  color="$( echo -e "\e[7;40;93m" )"
                ;;
                # *)# параметры по умолчанию
                # ;;
              esac

            fi
            shift
          ;;
        esac
      done


      # echo 'pipe='$pipe>&2

      if [ "$#" -ne 1 ]
        then
          status=$1;
          shift
          # много аргументов исключаем из вывода первый, это вместо shift
          # i=1
          # for arg in $@
          # do
            # if [ "$i" -ne 1 ]; then
              # # echo -n "xxx=$i"
              # msg+=" $arg"
            # fi
            # ((i += 1))
          # done
        # else
          # msg=$1
          # только один аргумент
      fi
      msg=$@
  fi

  # статус сообщения
  case "$status" in

    "e" | "E" | "err" | "error" | "ERROR")
    # color="\e[1;49;31m"
    color="$( echo -e "\e[1;49;31m" )"

    status="[ERROR] "
    stddirection=">&2;"
    ;;
    # Обратите внимание: блок кода, анализирующий конкретный выбор, завершается
    # двумя символами "точка-с-запятой".

    "w" | "W" | "warn" | "WARN")
    # color="\e[1;49;33m"
    color="$( echo -e "\e[1;49;33m" )"
    status="[WARN] "
    ;;

    "i" | "I" | "info" | "INFO")
    # color="\e[1;49;32m"
    color="$( echo -e "\e[1;49;32m" )"
    status="[INFO] "
    ;;

    "spec")
    color="$( echo -e "\e[7;40;96m" )"
    status=""
    ;;

    "event" | "action")
    # color="$( echo -e "\e[7;40;96m" )"
    [[ ! -n $color ]] && color="$( echo -e "\e[7;40;96m" )"
    msg="---------========${msg}========---------"
    status=""
    ;;

    * )
    # Выбор по-умолчанию.
    [[ ! -n $color ]] && color="$( echo -e "\e[1;40;96m" )"
    ;;
  esac
  # echo "${color}${status}$@${postfix}" $($stddirection)
  # echo "${color}${status}${msg}${new_line}${postfix}" >&2;
  # printf "%s" "${color}${status}${msg}${new_line}${postfix}" >&${pipe};
  echo -en "${color}${status}${msg}${new_line}${postfix}" >&${pipe};
}

# примеры запуска
# console_log
# console_log "без статуса"
# console_log '' по дефолту
# console_log E "очень опасно" 12345
# console_log W внимание

# останвалиет выполнение скрипта и выводит сообщение если переданы аргументы.
# Аргументы передаются в том же порядке что и console_log
function die {
  console_log $@
  exit 1
}
# die err "ОЙ что-то пошло не так"


join_by() {
    # Usage:  join_by "||" a b c d
    local arg arr=() sep="$1"
    shift
    for arg in "$@"; do
        if [ 0 -lt "${#arr[@]}" ]; then
            arr+=("${sep}")
        fi
        arr+=("${arg}") || break
    done
    printf "%s" "${arr[@]}"
}


array_intersect() {
  # так не получится т.к. все массивы передаются в виде строки агрументами
  intersections=()

  arr=("$@")
    for i in "${arr[@]}";
       do
           echo "$i"
       done

  console_log warn "x=$1"
  console_log warn "y=$2"
  for item1 in ${1[@]}; do
    console_log warn $item1
    for item2 in ${2[@]}; do
      if [[ $item1 == "$item2" ]]; then
          intersections+=( "$item1" )
          break
      fi
    done
  done

  printf '%s\n' "${intersections[@]}"
}

get_provider() {
    # получаем конфигурацию из провайдера
  # if [ -n $PROVIDER ] && [ -x $PATH_PWD/providers/$PROVIDER ]; then
  # if [ -n "${PROVIDER+set}" ]; then
  if [ -n "$PROVIDER" ]; then
    console_log WARN "Используется провайдер: $PROVIDER"
    if [ ! -x "${PATH_PWD}/providers/${PROVIDER}" ]
      then
        console_log ERROR "Файл провайдера '${PATH_PWD}/providers/${PROVIDER}' не существует либо отсутствуют разрешения на его выполнение! Прерываю работу"
        exit 10;
    fi
    source ${PATH_PWD}/providers/${PROVIDER}
  else
    console_log WARN "Провайдер не выбран, использую параметры по умолчанию"
  fi
}

get_host(){
  if [ -z "${DB_CONFIG_HOST}" ]; then
    console_log ERROR "Не смог получить значения из config.inc.php"
    console_log event $EVENT_NAME "\e[1mFINISHED\e[22m"
    exit 11;
    #statements
  fi
}