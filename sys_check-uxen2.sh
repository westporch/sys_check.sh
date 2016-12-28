#!/bin/bash
#Hyun-gwan Seo

function DRAW_A_LINE()
{
    echo -e "-----------------------------------------------"
}

function CHECK_MEMORY()
{
    free -h
    echo -e "-----------------------------------------------"
}


function PROCESS_CHECK()
{
    echo -e "\n-------- Process Check --------"

    process=("nginx" "uxen" "ntp")

    for ((idx=0; idx < ${#process[@]}; idx++))
    do
        echo "${process[$idx]}"
        echo -e "`ps aux | grep  ${process[$idx]}`"
        echo ""
    done
    DRAW_A_LINE
}

function VM_LIST_CHECK()
{
    echo -e "\n-------- VM List Check --------"
    sudo xl li
    DRAW_A_LINE
}

function DMESG_CHECK()
{
    echo -e "\n-------- Dmesg Check --------"
    dmesg -T | grep --color=yes error | tail
    DRAW_A_LINE
}

function UXEN_VERSION_CHECK()
{
    echo -e "\n--------- UXEN_VERSION Check ----------"
   
    cat /home/orchard/uxen/docs/VERSION | sed '2d' 2> /dev/null             # uxen2 (Version number)
    cat /var/www/uxen/docs/Changelog | head -n 2 | sed '1d' 2> /dev/null    # uxen2 (Revision number)  
    cat /opt/uxen3/docs/VERSION 2> /dev/null                                # uxen3 (Version number)

    DRAW_A_LINE
}

function VCPUS_RATIO_CHECK()
{
    echo -e "\n------ VCPUs Ration Check --------"

    cores=`sudo xl info | grep nr_cpus | awk -F ' ' '{ print $3 }'`
    vcpus=`sudo xl li | sed '1d' | awk -F' ' '{ sum += $4; } END { print sum; }'`

    #vcpus_ratio=`echo "scale=2; ($vcpus/$cores)*100" | bc`
    vcpus_ratio=`echo "$vcpus $cores" | awk '{printf "%.2f \n", $1/$2}'`
    echo -e "VCPUs 사용량(%) = $vcpus_ratio"
    DRAW_A_LINE
}

function BONDING_CHECK()
{
    echo -e "\n------ Bonding Down Check --------"
    grep --color=yes -r "down" /proc/net/bonding
    DRAW_A_LINE
}

function MULTI_PATH_CHECK()
{
    echo -e "\n--------- Multi Path Check --------"
    sudo multipath -ll
    DRAW_A_LINE
}

function OCFS2_CHECK()
{
    echo -e "\n-------- OCFS2 Check ---------"
    /etc/init.d/ocfs2 status
    /etc/init.d/o2cb status
    DRAW_A_LINE
}

function CHECK_DF()
{
    df -Th
    df -i
    DRAW_A_LINE
}

date
CHECK_MEMORY
PROCESS_CHECK
VM_LIST_CHECK
DMESG_CHECK
UXEN_VERSION_CHECK
VCPUS_RATIO_CHECK
BONDING_CHECK
MULTI_PATH_CHECK
OCFS2_CHECK
sudo nfsstat -m
CHECK_DF
ntpq -p
dstat -lcdngy 1 5

echo -e "\n"
Uxen2Version=`cat /home/orchard/uxen/docs/VERSION | sed '2d'`
Uxen3Version=`cat /opt/uxen3/docs/VERSION`
ManagementIP=`sudo ifconfig | grep "inet addr:192.168.0." | awk -F ':'  '{ print $2 }' | awk -F ' ' '{ print $1 }'`
echo -e "Your_value, `uname -n`, $Uxen2Version, $Uxen3Version, `sudo xl li | sed '1,2d' | wc -l`, $ManagementIP"
