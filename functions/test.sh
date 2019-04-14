#!/bin/bash

#usage: consoleLog 'Hello World'
consoleLog()
{
    echo '['$(date +'%a %Y-%m-%d %H:%M:%S %z')']' $1
}

#usage:
#setValue 'Enter something' 'defaultValue'
#VAR=$NEW_VALUE
setValue()
{
    read -p "$1 ("$2"): " NEW_VALUE
    if [ -z $NEW_VALUE ]; then
        NEW_VALUE=$2
    fi
}

function can-haz-args {
  echo "You gave me $# arguments: $@"
}

can-haz-args "one" 2 etc

# => "You gave me 3 arguments: one 2 etc"

meaning_of_life=42

function try_and_be_destructive {
  local meaning_of_life=39
}

try_and_be_destructive

echo "The meaning of life is $meaning_of_life"

# => The meaning of life is 42





function gimme_a_code {
  return 10
}
gimme_a_code
echo $?
# => 10


function strip {
  echo "$1" | tr -d " "
}

stripped=$(strip " lots of spaces  ")
# без разницы
# stripped=`strip " lots of spaces  "`


function echo_msg {
  local color='', status='', stddirection='', postfix="$( echo -e "\e[0m" )"
  # echo '['$(date +'%a %Y-%m-%d %H:%M:%S %z')']' $1
  case "$1" in
    # Обратите внимание: переменная взята в кавычки.

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

    * )
    # Выбор по-умолчанию.
    # color=\e[1;49;31m
    ;;
  esac

  # BOLD="$( echo -e "\e[1m" )"
  # CYAN="$( echo -e "\e[36m" )"
  # LAST="$( echo -e "\e[0m" )"
  #
  # echo "I am feeling ${BOLD}really ${CYAN}blue!${LAST}"

  echo "${color}${status}$@${postfix}" ($stddirection)
}

echo_msg E message

f3(){ echo "last: $var1";}
var1='global'
f1(){ echo "$var1"; local var1='f1'; f2;}
f2(){ echo "$var1"; f3;}
f1

echo -e "Normal \e[5mBlink"
echo -e "Normal \e[4mUnderlined"

#Background
# for clbg in {40..47} {100..107} 49 ; do
# 	#Foreground
# 	for clfg in {30..37} {90..97} 39 ; do
# 		#Formatting
# 		for attr in 0 1 2 4 5 7 ; do
# 			#Print the result
# 			echo -en "\e[${attr};${clbg};${clfg}m ^[${attr};${clbg};${clfg}m \e[0m"
# 		done
# 		echo #Newline
# 	done
# done
#
# exit 0

function do_or_die {
  $@ || { echo "Command failed: $@" && exit 1; }
}

do_or_die test -f /important/file
echo "Phew, everything's fine"
# => "Command failed: test -f /important/file"


function die {
  echo "[ERROR]: $@">&2;
  exit 1
}

echo "I'm dying!"
die
echo "I'm alive!"
#=> "I'm dying!"
