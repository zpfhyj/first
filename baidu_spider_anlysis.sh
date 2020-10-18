#!/bin/bash
#
#create by zpf 2018-12-3
#
RED_COLOR='\E[1;31m'
RES='\E[0m'
LOG_DIR=/mnt/data/log/website
#LOG_DIR=/root/zpf
OUT_DIR=/mnt/data/log/website/2020/baidu_spider_anlysis
#FILE_NAME=anlysied_`date +%s`.txt
FILE_NAME=anlysied_`date +"%Y-%m-%d-%H:%m:%S"`.txt

if [ $# == 0 ];then
	echo -e "\E[1;31mUsage \"$0 log_file_name\" \E[0m"
	exit 0
fi
for I in $@
do
	echo -e "##########$I 分析结果如下##########" >> $OUT_DIR/${I}_${FILE_NAME}
	echo -e "百度抓取总次数：`grep "Baiduspider" $LOG_DIR/$I|wc -l`" >> $OUT_DIR/${I}_${FILE_NAME}
	echo -e "百度蜘蛛抓取的各个状态码次数：\t状态码次数\t状态码" >> $OUT_DIR/${I}_${FILE_NAME}
        grep "Baiduspider" $LOG_DIR/$I |awk -F '"' '{print $3}' |awk '{print $1}' |sort -nr |uniq -c |sort -nr >> $OUT_DIR/${I}_${FILE_NAME}
	echo -e "百度蜘蛛抓取的404状态码目录（前20）：" >> $OUT_DIR/${I}_${FILE_NAME}
        grep "Baiduspider" $LOG_DIR/$I|awk '$10==404 {print $8}'|awk -F '/' '{print $1"/"$2}' |sort |uniq -c |sort -nr |head -n 20 >> $OUT_DIR/${I}_${FILE_NAME}
        echo -e "百度蜘蛛抓取的各个链接数: \t抓取次数\t抓取链接" >> $OUT_DIR/${I}_${FILE_NAME}
	grep "Baiduspider" $LOG_DIR/$I|awk -F '"' '{print $2}'|awk '{print $2}' |sort -nr |uniq -c  |sort -rn >> $OUT_DIR/${I}_${FILE_NAME}
	echo -e "\n\n\n百度蜘蛛抓取的时间1s-5s的：" >> $OUT_DIR/${I}_${FILE_NAME}
	awk -F '"' '1<$(NF-1) && $(NF-1)<5 {print $0}' $LOG_DIR/$I |grep "Baiduspider"|awk -F '"' '{print "后端处理状态码："$(NF-5)",请求链接："$2" ,nginx响应时间："$(NF-1)", 后端链接时间："$(NF-3)}' >> $OUT_DIR/${I}_${FILE_NAME}
        echo -e "\n\n\n百度蜘蛛抓取时间超过5s的：" >> $OUT_DIR/${I}_${FILE_NAME}
        awk -F '"' ' $(NF-1)>5 {print $0}' $LOG_DIR/$I |grep "Baiduspider"|awk -F '"' '{print "后端处理状态码："$(NF-5)",请求链接："$2" ,nginx响应时间："$(NF-1)", 后端链接时间："$(NF-3)}' >> $OUT_DIR/${I}_${FILE_NAME}


echo -e "\E[1;31m ${I}日志文件分析完成，详细结果查看 $OUT_DIR/${I}_${FILE_NAME} \E[0m `date +"%Y-%m-%d %H:%m:%S"`" >>/var/log/log_anlysis.log
done

