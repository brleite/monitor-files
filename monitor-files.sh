#!/bin/bash 

export PYTHONPATH=/opt/python-modules/telegram-bot
BASEDIR=$(dirname "$0")

PROPERTY_FILE=$BASEDIR/config.txt
PYTHON_NOTIFY=$BASEDIR/notify.py
TMP_DIR=/tmp
CURRENT_FILE_PREFIX=monitor_files_current
LAST_FILE_PREFIX=monitor_files_last
SUCCESS_MESSAGE_SUFIX="encontrado"
ERROR_MESSAGE_SUFIX="não encontrado"
FLAG="SUCESSO"

function getProperty {
  PROP_KEY=$1
  PROP_VALUE=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
  echo $PROP_VALUE
}

echo "# Reading property from $PROPERTY_FILE"
MONITOR_FILES=$(getProperty "monitor.files")

echo $MONITOR_FILES

IFS=','
for file_message in $MONITOR_FILES ; do 
  echo "Verificando arquivo \"$file_message\""

  IFS='|'; arrIN=($file_message); unset IFS;
  file=${arrIN[0]}
  message=${arrIN[1]}
  IFS=','
  
  file_log=`echo $file | sed 's/\//_/g'`

  current_log_file=$TMP_DIR'/'$CURRENT_FILE_PREFIX$file_log  
  last_log_file=$TMP_DIR'/'$LAST_FILE_PREFIX$file_log  
  
  # echo $current_log_file
  # echo $last_log_file

  ls $file
  retVal1=$?
  
  if [ $retVal1 -ne 0 ]; then
    echo "Erro ao listar arquivo $file"
  fi

  current_flag=`cat $file`
  retVal2=$?

  if [ $retVal2 -ne 0 ]; then
    echo "Erro ao exibir conteúdo do arquivo $file"
  fi
  
  drive=`echo $file | cut -d '/' -f 2`
  drive="/$drive"

  ls $drive
  retVal3=$?

  if [ $retVal3 -ne 0 ]; then
    echo "Erro ao listar drive $drive"
  fi

  if [ $retVal1 -ne 0 ] || [ $retVal2 -ne 0 ] || [ $retVal3 -ne 0 ] || [ "$current_flag" != "$FLAG" ]; then
    echo "Arquivo inexistente"
    flag_controle=1
    
    if [ -f "$current_log_file" ]; then
      current_value=`cat $current_log_file`

      if [ $current_value == "0" ]; then
        echo "Enviando notificacao"
        python3 $PYTHON_NOTIFY "$message $ERROR_MESSAGE_SUFIX"
        
        echo $current_value > $last_log_file
        echo $flag_controle > $current_log_file
      else
        echo "Não é preciso enviar notificação"
        echo $current_value > $last_log_file
        echo $flag_controle > $current_log_file
      fi
    else
      echo "Enviando notificacao"
      python3 $PYTHON_NOTIFY "$message $ERROR_MESSAGE_SUFIX"

      echo "0" > $last_log_file
      echo $flag_controle > $current_log_file 
    fi
  else
    echo "Arquivo existente"
    flag_controle=0

    if [ -f "$current_log_file" ]; then
      current_value=`cat $current_log_file`

      if [ $current_value == "0" ]; then
        echo "Não precisa de notificacao"

        echo $current_value > $last_log_file
        echo $flag_controle > $current_log_file
      else
        echo "Enviando notificação"
        python3 $PYTHON_NOTIFY "$message $SUCCESS_MESSAGE_SUFIX"

        echo $current_value > $last_log_file
        echo $flag_controle > $current_log_file
      fi
    else
      echo "Enviando notificacao"
        python3 $PYTHON_NOTIFY "$message $SUCCESS_MESSAGE_SUFIX"

      echo "0" > $last_log_file
      echo $flag_controle > $current_log_file
    fi
  fi
done
