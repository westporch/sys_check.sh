#/bin/bash
#Hyun-gwan Seo

function PROCESS_CHECK()
{
    echo -e "-------- Process Check --------\n"

    process=("nginx" "uxen" "ntp")

    for ((idx=0; idx < ${#process[@]}; idx++))
    do
        echo "${process[$idx]}"
        echo -e "`ps aux | grep  ${process[$idx]}`"
        echo ""
    done
    echo -e "-----------------------------------------------"
}

function UXEN_VERSION_CHECK()
{
    echo -e "--------- UXEN_VERSION Check ----------\n"
    cat /home/orchard/uxen/docs/VERSION 2> /dev/null
    cat /var/www/uxen/docs/Changelog | head -n 2 | sed '1d'
    echo -e "-----------------------------------------------"

}

function VCPUS_RATIO_CHECK()
{
    echo -e "------ VCPUs Ration Check --------\n"

    cores=`sudo xl info | grep nr_cpus | awk -F ' ' '{ print $3 }'`
    vcpus=`sudo xl li | sed '1d' | awk -F' ' '{ sum += $4; } END { print sum; }'`

    #vcpus_ratio=`echo "scale=2; ($vcpus/$cores)*100" | bc`
    vcpus_ratio=`echo "$vcpus $cores" | awk '{printf "%.2f \n", $1/$2}'`
    echo -e "VCPUs 사용량(%) = $vcpus_ratio"
    echo -e "-----------------------------------------------"

}

function MULTI_PATH_CHECK()
{
    echo -e "--------- Multi Path Check --------\n"
    sudo multipath -ll
    echo -e "-----------------------------------------------"

}

function OCFS2_CHECK()
{
    echo -e "-------- OCFS2 Check ---------\n"
    /etc/init.d/ocfs2 status
    /etc/init.d/o2cb status
    echo -e "-----------------------------------------------"
}

date
PROCESS_CHECK
UXEN_VERSION_CHECK
VCPUS_RATIO_CHECK
MULTI_PATH_CHECK
OCFS2_CHECK
sudo nfsstat -m
df -Th

echo -e "\n"
UxenVersion=`cat /var/www/uxen/docs/Changelog | head -n 2 | sed '1d'`
ManagementIP=`sudo ifconfig | grep "inet addr:192.168.0." | awk -F ':'  '{ print $2 }' | awk -F ' ' '{ print $1 }'`
echo -e "Your_value, `uname -n`, $UxenVersion, `sudo xl li | sed '1,2d' | wc -l`, $ManagementIP"
