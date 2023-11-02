#!/bin/bash
## CPU Idle
snap_top=`top -n 1`
#echo $snap_top
current_load=` echo "$snap_top" | grep load | awk '{print $12}' | sed 's/,//g' `
#echo "current load: $current_load "
cpu_id=`echo "$snap_top" | grep Cpu | awk '{print $8}' | cut -d. -f1`

#cpu_id=`echo "($cpu_i+0.5)/1" | bc`

if [[ $cpu_id -gt 20 ]]
then
        echo -e "CPU Idle: $cpu_id%                     \e[0;32m[ok]\e[0m"
else
        echo -e "CPU Idle: $cpu_id%                     \e[0;31m[Critical]\e[0m"
fi
## CPU Usage
cpu_user=`echo "$snap_top" | grep Cpu | awk '{print $2}'`
cpu_sys=`echo "$snap_top" | grep Cpu | awk '{print $4}'`

cpu_usage=`echo $cpu_user + $cpu_sys | bc -l`

#echo "Cpu User: $cpu_user And CPU System: $cpu_sys"

if [[ $( echo "$cpu_usage < 80.0" | bc -l ) -eq 1 ]]
then
        echo -e "CPU Usage(%): $cpu_usage%              \e[0;32m[ok]\e[0m"
else
        echo -e "CPU Usage(%): $cpu_usage%              \e[0;31m[Critical]\e[0m"
fi

## CPU Load
no_processors=`cat /proc/cpuinfo | grep processor | wc -l `
#echo $no_processors
#c_load_p=
load_c=`bc <<< "$current_load * 100 / $no_processors" `
#load_c=`bc <<< "$load_cp * 100"`

#echo $load_c
if [[ $load_c -lt 80 ]]
then
        echo -e "CPU Load(%): $load_c%          \e[0;32m[ok]\e[0m"
else
        echo -e "CPU Load(%): $load_c%          \e[0;31m[Critical]\e[0m"
fi

## Memory Utilization
t_mem=`free -m | grep Mem | awk '{print $2}' | cut -d'M' -f1`
#echo "$t_mem"
a_mem=`free -m | grep Mem | awk '{print $7}' | cut -d'M' -f1`
#echo "$a_mem"
p_mem_use=`bc -l <<< "scale=2; ($a_mem / $t_mem) * 100"`
mem_lt="80.00"
if [[ $(echo "$p_mem_use < $mem_lt"| bc) -eq "1" ]]
then
        echo -e "Memory Utilization : $p_mem_use%       \e[0;32m[ok]\e[0m"
else
        echo -e "Memory Utilization : $p_mem_use%       \e[0;31m[Critical]\e[0m"
fi

## Disk Utilization
np=`df -h | awk '{print $5}' | wc -l `
npc=1
#df -h | awk '{print $5}' | head -$np | tail -1
#for i in $(seq 1 10);
for (( i=2; i <= $np; i++ ));
do
  dup=`df -h | awk '{print $5}' | head -$i | tail -1 | cut -d'%' -f1 `
  if [[ $dup -lt 80 ]]
  then
        npc=$((npc + 1))
  fi
done
#echo $np
#echo $npc
if [[ $np -eq $npc ]]
then
        echo -e "Disk Utilization is:           \e[0;32m[ok]\e[0m"
else
        echo -e "Disk Utilization is:           \e[0;31m[Critical]\e[0m"
        echo "`df -h | head -1`"
        for (( i=2; i <= $np; i++ ));
        do
                dup=`df -h | awk '{print $5}' | head -$i | tail -1 | cut -d'%' -f1 `
                if [[ $dup -gt 80 ]]
                then
                        exli=`df -h | awk '{print $5}' | head -$i | tail -1`
                        echo "`df -h | grep $exli`"
                fi
        done
fi

# Services check
echo " "
echo "All Service Status:"
a_service=("nessusagent" "splunk" "dcservice" "mcafee.ma" "falcon-sensor" "httpd")
for str in ${a_service[@]}
do
        s_status=`systemctl is-active $str`
        if [[ $s_status == 'active' ]]
        then
                echo -e "$str is                        \e[0;32m$s_status\e[0m"
        fi
done
