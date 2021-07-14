#!/bin/bash
#
#create by zpf 2021-07
#

#log store path
LOG_STORE=/mnt/data/log/website
LOG_YEAR=`date -d "yesterday" +"%Y"`
LOG_PATH=`date -d "yesterday" +"%m"`

LOG_FILE_PATH=${LOG_STORE}/${LOG_YEAR}/${LOG_PATH}
LOG_FILE_DATE=`date -d "yesterday" +"%Y%m%d"`
DAY_LOG_FILE=''

#log anly result store
FILE_NAME=`date -d "yesterday" +"%Y%m%d"`
WORK_PATH=/mnt/data/log/spider_anly
MK_WORK_PATH () {
    for I in baidu 360 souhu shenma toutiao
    do
	if [ ! -d ${WORK_PATH}/$I/${FILE_NAME} ];then
        	mkdir -p ${WORK_PATH}/$I/${FILE_NAME}
        fi  
    done      
}
#脚本使用说明，需要日志文件名称
if [ $# == 0 ];then
	echo -e "\E[1;31mUsage \"$0 log_file_name\" \E[0m"
	exit 0
fi
#生成目录
MK_WORK_PATH

#main 
#日志文件名称去拼凑前一日的日志文件名字（日志切割另有他人写，名称以及存储路径比较奇葩）
for LOG_FILE in $@
do
    PATH_NAME=`echo $LOG_FILE |awk -F'.' '{print $1}'`
    if [ ${PATH_NAME} == 'web' ];then
	DAY_LOG_FILE=${LOG_FILE_PATH}/${PATH_NAME}.access_`date -d "yesterday" +"%Y%m%d"`.log
    else
    	DAY_LOG_FILE=${LOG_FILE_PATH}.${PATH_NAME}/${PATH_NAME}.access_`date -d "yesterday" +"%Y%m%d"`.log
    fi
   echo ${DAY_LOG_FILE}

    for CHANGSHANG in baidu 360 souhu shenma toutiao
    do
        case ${CHANGSHANG} in
                "baidu")
                    grep -E "Baiduspider|baiduspider" ${DAY_LOG_FILE}|awk '{print $(NF-1),"  ",$2," ",$5," ",$8," ",$10," "$11,"  Baiduspider*"}' >> ${WORK_PATH}/${CHANGSHANG}/${FILE_NAME}/${LOG_FILE}_baiduSpider.txt
                    ;;
                 "360")
                     grep -E "360spider" ${DAY_LOG_FILE}|awk '{print $(NF-1)," ",$2," ",$5," ",$8," ",$10," "$11," 360spider*"}' >> ${WORK_PATH}/${CHANGSHANG}/${FILE_NAME}/${LOG_FILE}_360Spider.txt
                     grep -E "HaoSouSpider" ${DAY_LOG_FILE}|awk '{print $(NF-1)," ",$2," ",$5," ",$8," ",$10," "$11," HaoSouSpider*"}' >> ${WORK_PATH}/${CHANGSHANG}/${FILE_NAME}/${LOG_FILE}_360Spider.txt
                     ;;
                  "souhu")
                      grep -E "Sosospider|sogou|Sogou" ${DAY_LOG_FILE}|awk '{print $(NF-1)," ",$2," ",$5," ",$8," ",$10," "$11," Sosospider|sogou|Sogou*"}' >> ${WORK_PATH}/${CHANGSHANG}/${FILE_NAME}/${LOG_FILE}_sgouSpider.txt
                      ;;
                   "shenma")
                       grep -E "Yisouspider" ${DAY_LOG_FILE}|awk '{print $(NF-1)," ",$2," ",$5," ",$8," ",$10," "$11,"  Yisouspider*"}' >> ${WORK_PATH}/${CHANGSHANG}/${FILE_NAME}/${LOG_FILE}_shenmaSpider.txt
                       ;;
                    "toutiao")
                        grep -E "Bytespider" ${DAY_LOG_FILE}|awk '{print $(NF-1)," ",$2," ",$5," ",$8," ",$10," "$11," Bytespider*"}' >> ${WORK_PATH}/${CHANGSHANG}/${FILE_NAME}/${LOG_FILE}_Bytespider.txt
                        ;;
                     *)
                     ;;
          esac                
    done
done
