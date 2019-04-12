#!/usr/bin/env bash
# fork this file from https://github.com/evandrocoan/.versioning/blob/master/install_githooks.sh

# Reliable way for a bash script to get the full path to itself?
# http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
pushd `dirname $0` > /dev/null
PATH_PWD=`pwd`
popd > /dev/null

configuration_file=$1

GIT_DIR_="$(git rev-parse --git-dir)"
PROJECT_ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
gitHooksPath="$GIT_DIR_/hooks"
TARGET='local'

source $PATH_PWD/function/common.sh
source $PATH_PWD/function/bash-ini-parser/bash-ini-parser
cfg_parser $PATH_PWD/config.ini
source $PATH_PWD/function/parse_args.sh

# получим цель для какой части берутся хуки, т.к. для девелоп сервера
# и локального клиентского компа они разные
while (( "$#" )); do
    case "$1" in
      -t=*|--target=*)
        if [[ "${1,,}" == *"="* ]]; then
          TARGET=`echo $1 | sed -E 's/(.*=)//'`
        fi
      ;;
    esac
    shift
done

console_log warn "Current target: ${TARGET}"

HOOKS_PATH="$PATH_PWD/hooks/$TARGET"

# Remove the '/app/blabla/' from the $PATH_PWD variable to get its base folder name.
# https://regex101.com/r/rR0oM2/1
AUTO_VERSIONING_ROOT_FOLDER_NAME=$(echo $PATH_PWD | sed -r "s/((.+\/)+)//")

# Get the folder to the auto-versioning scripts from the git root directory.
AUTO_VERSIONING_ROOT_FOLDER_PATH="$(git rev-parse --show-prefix)$AUTO_VERSIONING_ROOT_FOLDER_NAME"

# echo
# echo "pwd                              : $(pwd)"
# echo "GIT_DIR_                         : $GIT_DIR_"
# echo "PATH_PWD                         : $PATH_PWD"
# echo "gitHooksPath                     : $gitHooksPath"
# echo "configuration_file               : $configuration_file"
# echo "PROJECT_ROOT_DIRECTORY           : $PROJECT_ROOT_DIRECTORY"
# echo "AUTO_VERSIONING_ROOT_FOLDER_NAME : $AUTO_VERSIONING_ROOT_FOLDER_NAME"
# echo "AUTO_VERSIONING_ROOT_FOLDER_PATH : $AUTO_VERSIONING_ROOT_FOLDER_PATH"
if [ ! -d $HOOKS_PATH ];then
    console_log err "Error! Could not to install the githooks."
    console_log err "The source hooks folder \`$HOOKS_PATH\` folder is missing."
    exit 1
fi

if [ -d $gitHooksPath ]
then
    console_log -c=green "Installing the githooks..."

    # Set the scripts file prefix
    scripts_folder_prefix="hooks/${TARGET}"

    # source_path="${PATH_PWD}/$scripts_folder_prefix/*"
    source_path="${PATH_PWD}/$scripts_folder_prefix/"
    # for hook_file in $source_path
    # ?*.* отображает файлы без расширения
    # find $source_path -name "*.*" -print0 | while read -d $'\0' hook_file
    find $source_path -maxdepth 1 -type f ! -name "*.*" -print0 | while read -d $'\0' hook_file
    do
        hook_file_name=$(echo $hook_file | sed -r "s/((.+\/)+)//")
        TMPFILE=$(mktemp)

        console_log "Current hook file: ${hook_file}"
        console_log "Copy hook into: ${gitHooksPath}/${hook_file_name}";

        # заменяем перенос строки
        cat $hook_file > $TMPFILE;
        sed 's/\#%%%%%%/DB\_SVN\_PATH\=\"'$(echo -en "${AUTO_VERSIONING_ROOT_FOLDER_NAME}")'\"/g' $TMPFILE > "${gitHooksPath}/${hook_file_name}"
    done

    console_log -c=bg_green "\nThe githooks are successfully installed!"
else
    console_log err "Error! Could not to install the githooks."
    console_log err "The git hooks folder \`$gitHooksPath\` folder is missing."
    exit 1
fi

exit 0