#!/usr/bin/env bash

PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
SCRIPT_DIR=$(dirname $0)
LOGS_DIR="${SCRIPT_DIR}/logs"

function info() {
  echo "[INFO] $@"
}


function fatal() {
  echo "[FATAL] $@"
  exit 1;
}

function gen_logs() {
  local file=$1
  local noOfLine=$2

  for((i=0; i<$noOfLine; i++))
    do
      echo "The quick brown fox jumps over the lazy dog."
  done > $LOGS_DIR/${file}

}

function rotate_logs() {
  local file=$1
  local threshold=$2

  if test -f $LOGS_DIR/$file && test ! -z $LOGS_DIR/$file;
    then
      lineCount=$(wc -l $LOGS_DIR/$file | awk '{print $1}')

      if test $lineCount -gt $threshold;
	then
          newFile="${file}.$(date +%s)"
	  mv $LOGS_DIR/$file $LOGS_DIR/$newFile && \
	  echo "The '$LOGS_DIR/$file' has been renamed to '$LOGS_DIR/$newFile'."
      fi
  fi
}

function clean_logs() {
  local threshold=$1
  local noOfFiles=$(ls -1 ${SCRIPT_DIR}/logs | wc -l)

  if test $noOfFiles -gt $threshold;
    then
      arr=($(ls -1t ${SCRIPT_DIR}/logs))

      for((i=$threshold; i<${#arr[@]}; i++));
        do
	  echo "Removing $LOGS_DIR/${arr[$i]}"
	  rm $LOGS_DIR/${arr[$i]}
      done	
  fi
}


# Main
if test $(id -u) -eq 0;
  then
    fatal "You must not run the script as root user."
fi

test -d ${SCRIPT_DIR}/logs || fatal "The 'logs' directory is not present."

test ${#@} -ne 0 || fatal "Needs at least one argument, can be gen, rotate, or clean."

case $1 in
  "gen")
	gen_logs "earth-log" "50"
	;;
  "rotate")
	rotate_logs "earth-log" "20"
	;;
  "clean")
	clean_logs "5"
	;;
  *)
	fatal "Invalid parameter $1, provide one of gen, rotate, or clean."
	;;
esac
