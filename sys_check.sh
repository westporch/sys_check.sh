#!/bin/bash
#Hyun-gwan Seo

function DRAW_A_LINE()
{
    echo -e "-----------------------------------------------"
}

function GET_DATE()
{
    echo -e "\n------------------- date-------------------"
    date
    ntpq -p
}

function CHECK_MEMORY()
{
    echo -e "\n-------------- Check memory --------------"
    free -h
    DRAW_A_LINE
}


function CHECK_PROCESS()
{
    echo -e "\n-------------- Check Process --------------"

    process=("nginx" "uxen" "ntp")

    for ((idx=0; idx < ${#process[@]}; idx++))
    do
        echo "${process[$idx]}"
        echo -e "`ps aux | grep  ${process[$idx]}`"
        echo ""
    done
    DRAW_A_LINE
}

function RUN_DSTAT()
{
    echo -e "\n-------------- dstat  --------------"
    dstat -lcdngy 1 10
    dstat -nf 1 10
    DRAW_A_LINE

}

function GET_VM_LIST()
{
    echo -e "\n-------------- VM List Check --------------"
    sudo xl li
    DRAW_A_LINE
}

function DMESG_CHECK()
{
    echo -e "\n-------------- Dmesg Check --------------"
    dmesg -T | grep --color=yes ERROR | tail
    DRAW_A_LINE
}

function GET_UXEN_VERSION()
{
    echo -e "\n--------------- UXEN_VERSION Check ----------------"
   
    cat /home/orchard/uxen/docs/VERSION  | sed '2d'            # uxen2 (Version number)
    cat /var/www/uxen/docs/Changelog  | head -n 2 | sed '1d'   # uxen2 (Revision number)  
    cat /opt/uxen3/docs/VERSION 2> /dev/null                   # uxen3 (Version number)

    DRAW_A_LINE
}

function GET_XL_INFO()
{
    echo -e "\n----------------- xl info --------------------"
    xl info | grep -E "total_memory|free_memory"
    DRAW_A_LINE
}

function VCPUS_RATIO_CHECK()
{
    echo -e "\n------------ VCPUs Ration Check --------------"

    cores=`sudo xl info | grep nr_cpus | awk -F ' ' '{ print $3 }'`
    vcpus=`sudo xl li | sed '1d' | awk -F' ' '{ sum += $4; } END { print sum; }'`

    #vcpus_ratio=`echo "scale=2; ($vcpus/$cores)*100" | bc`
    vcpus_ratio=`echo "$vcpus $cores" | awk '{printf "%.2f \n", $1/$2}'`
    echo -e "VCPUs 사용량(%) = $vcpus_ratio"
    DRAW_A_LINE
}

function CHECK_BONDING()
{
    echo -e "\n------------ Bonding Down Check --------------"
    grep --color=yes -r "down" /proc/net/bonding 2> /dev/null
    DRAW_A_LINE
}

function GET_BRIDGE()
{
    echo -e "\n---------------- brctl show ------------------"
    brctl show
    DRAW_A_LINE
}

function CHECK_MULTI_PATH()
{
    echo -e "\n--------------- Multi Path Check --------------"
    sudo multipath -ll
    DRAW_A_LINE
}

function CHECK_OCFS2()
{
    echo -e "\n-------------- OCFS2 Check ---------------"
    /etc/init.d/ocfs2 status
    /etc/init.d/o2cb status
    DRAW_A_LINE
}

function CHECK_NFS()
{
    echo -e "\n--------------- NFS Check ---------------"
    nfsstat -m
    DRAW_A_LINE
}

function CHECK_DF()
{
    echo -e "\n---------------- df -Th ------------------"
    df -Th
    echo -e "\n---------------- df -i -------------------"
    df -i
    DRAW_A_LINE
}

LOG_HOME=/var/log

# /var/log/syslog* 파일을 하나로 합치고 불필요한 로그를 삭제함.
function REFINE_SYSLOG()
{
    echo -e "\n---------------- Refine /var/log/syslog* ------------------"

    ENTIRE_SYSLOG=/tmp/entire_syslog
    REFINED_SYSLOG=/tmp/refined_syslog

    ls -r $LOG_HOME/syslog*.gz | xargs zcat > $ENTIRE_SYSLOG
    sudo cat $LOG_HOME/syslog.1 >> $ENTIRE_SYSLOG
    sudo cat $LOG_HOME/syslog >> $ENTIRE_SYSLOG

    # cron에 등록되면 자동으로 메일이 발송됨. 메일을 안쓰므로 no MTA installed 메시지는 무시해도 됨.
    cat $ENTIRE_SYSLOG | grep -Ev "Connection from UDP|orchard|irqbalance|drop_caches|MTA" > $REFINED_SYSLOG

    echo -e "Please see /tmp/refined_syslog"
    
}

# /var/log/message* 파일을 하나로 합치고 불필요한 로그를 삭제함.
function REFINE_MESSAGES()
{
    echo -e "\n---------------- Refine /var/log/messages* ------------------"

    ENTIRE_MESSAGE_LOG=/tmp/entire_messages

    ls -r $LOG_HOME/messages*.gz | xargs zcat > $ENTIRE_MESSAGE_LOG
    sudo cat $LOG_HOME/messages.1 >> $ENTIRE_MESSAGE_LOG
    sudo cat $LOG_HOME/messages >> $ENTIRE_MESSAGE_LOG

    cat $ENTIRE_MESSAGE_LOG | grep -Ev "Failed|error|ERROR|rsyslogd" > /tmp/refined_messages
    echo -e "Please see /tmp/refined_messages"
}

# /var/log/kern.log* 파일을 하나로 합침.
function REFINE_KERN_LOG()
{
    echo -e "\n---------------- Refine /var/log/kern.log* ------------------"

    ENTIRE_KERN_LOG=/tmp/entire_kern.log

    ls -r $LOG_HOME/kern.log*.gz | xargs zcat > $ENTIRE_KERN_LOG
    sudo cat $LOG_HOME/kern.log.1 >> $ENTIRE_KERN_LOG
    sudo cat $LOG_HOME/kern.log >> $ENTIRE_KERN_LOG
    echo -e "Please see /tmp/refined_kern.log"
}

# /var/log/auth.log 파일을 하나로 합치고 불필요한 로그를 삭제함.
function REFINE_AUTH_LOG()
{
    echo -e "\n---------------- Refine /var/log/auth.log* ------------------"
    ENTIRE_AUTH_LOG=/tmp/entire_auth.log

    ls -r $LOG_HOME/auth.log*.gz | xargs zcat > $ENTIRE_AUTH_LOG
    sudo cat $LOG_HOME/auth.log.1 >> $ENTIRE_AUTH_LOG
    sudo cat $LOG_HOME/auth.log >> $ENTIRE_AUTH_LOG

    # failure 또는 FAILED가 포함된 라인을 추출함
    cat $ENTIRE_AUTH_LOG | grep -E "failure|FAILED" > /tmp/refined_auth.log 
    echo -e "Please see /tmp/refined_auth.log"
}

function GET_SYSTEM_LOG()
{
    REFINE_SYSLOG
    REFINE_MESSAGES
    REFINE_KERN_LOG
    REFINE_AUTH_LOG
}


function GET_SUMMARY()
{
    echo -e "\n"
    Uxen2Version=`cat /home/orchard/uxen/docs/VERSION 2> /dev/null | sed '2d'`
    Uxen3Version=`cat /opt/uxen3/docs/VERSION 2> /dev/null`
    ManagementIP=`sudo ifconfig | grep "inet addr:192.168.0." | awk -F ':'  '{ print $2 }' | awk -F ' ' '{ print $1 }'`
    echo -e "Your_value, `uname -n`, $Uxen2Version, $Uxen3Version, `sudo xl li | sed '1,2d' | wc -l`, $ManagementIP"
}

function MAIN()
{
    GET_DATE
    CHECK_PROCESS
    RUN_DSTAT
    GET_VM_LIST
    GET_UXEN_VERSION
    GET_XL_INFO
    VCPUS_RATIO_CHECK
    CHECK_BONDING
    CHECK_MULTI_PATH
    CHECK_OCFS2
    CHECK_NFS
    CHECK_DF
    CHECK_MEMORY

    DMESG_CHECK
    GET_SYSTEM_LOG

    GET_SUMMARY
}

MAIN
