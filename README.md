5. Найдите способ обнаружить в системе исходный код скрипта, который выполняется, но был удалён.

Используя команду lsof, ищу удалённые файлы, которые еще остаются открытыми процессами.

sudo lsof | grep deleted

none       733                           root  txt       REG                0,1     17032      26840 / (deleted)
script.sh 1531                           root  255r      REG              252,2        64       4410 /opt/script.sh (deleted)

PID 1531 , вывожу содержимое в окно терминала через файловый дескриптор

sudo cat /proc/1531/fd/255

#!/bin/bash
while true; do
  date >> /opt/my.log
  sleep 1
done
