#!/bin/bash

# Считываем параметры
VmailDir=$1
ListVmailDir=$2
VmailStorDir=$3

if [ $(ls -1 "$VmailDir" | wc -l) -ne 0 ]
then
    # Получаем список файов
    mkdir -p "$ListVmailDir"
    CurDir=$(pwd)
    cd "$VmailDir"
    ls -1 *.wav | sed s/.wav//  > "$ListVmailDir/voice-mail.log"
    cd "$CurDir"
    NumFilesInDir=$(cat "$ListVmailDir/voice-mail.log" | wc -l)
    
   for (( i=1; i <= $NumFilesInDir; i++ ))
   do
    # Забираем имя исходного файла
    OrigFileName=$(head -n $i "$ListVmailDir/voice-mail.log" | tail -n 1)
    
    # Забираем дату для имени файла
    FileDate=$(grep -E 'ysdate' "$VmailDir/$OrigFileName.txt" | sed s/ysdate=//g | tr ' ' '-' | tr ':' '-')
    
    # Забираем номер телефона для имени файла
    FilePhone=$(grep -E 'callerid' "$VmailDir/$OrigFileName.txt" | sed s/callerid=//g | sed 's/<.*//' | sed 's/"//g' | tr ' ' '-' | sed 's/.$//')
    
    # Составляем имя для нового файла
    NewFileName=$(echo "$FileDate-$FilePhone")
    
    # Составляем имена для папок с файлами
    DateDir=$(grep -E 'ysdate' "$VmailDir/$OrigFileName.txt" | sed s/ysdate=//g | tr ' ' '\n' | sed 2d)
    # Создаем папку для файлов
    mkdir -p "$VmailStorDir/$DateDir"
    
    # Перемещаем файл с новым именем
    mv "$VmailDir/$OrigFileName.wav" "$VmailStorDir/$DateDir/$NewFileName.wav"
    rm "$VmailDir/$OrigFileName.txt"
   done
else
    echo "Directory is empty. Nothing to do."
fi

exit 0
