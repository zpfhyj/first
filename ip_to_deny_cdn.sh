#/bin/bash
#
#create by zpf 2020-05-09
#
#nginx文件的相关检测
NGINX_BIN=/usr/local/nginx/sbin/nginx
DENY_CONF=/usr/local/nginx/conf/deny.conf
WITELIST=/usr/local/nginx/conf/witelist.conf
WITE_IP=`cat $WITELIST`
rep_info() { echo;echo -e "$*";echo; }
rep_error(){ echo;echo -e "$*";echo; }
#日志文件
logfile=/mnt/data/log/website/
#logfile=/usr/local/nginx/logs/
#检测时间间隔
last_minutes=30
#函数定义
reload_nginx()
{
    $NGINX_BIN -t >/dev/null 2>&1 && \
    $NGINX_BIN -s reload && \
    return 0
}
show_list()
{
   awk -F '["){|]' '/if/ {for(i=2;i<=NF;i++) if ($i!="") printf $i"\n"}' $DENY_CONF 
}

create_rule()
{
test -f $DENY_CONF && \
rep_error "$DENY_CONF already exist!."
cat >$DENY_CONF<<EOF
if (\$http_x_forwarded_for ~* "8.8.8.8") {
    return 400;
    break;
}
EOF
test -f $DENY_CONF && \
rep_info "$DENY_CONF create success!" && \
cat $DENY_CONF && \
exit 0

rep_error "$DENY_CONF create failed!" && \
exit 1

}
pre_check()
{
    test -f $NGINX_BIN || rep_error "$NGINX_BIN not found,Plz check and edit."
    test -f $DENY_CONF || create_rule

    #MATCH_COUNT=$(show_list | grep -w $1 | wc -l)
    #return $MATCH_COUNT
}

add_ip()
{
    pre_check $1
    if [[ $? -eq 0 ]];then
        echo "deny $1;">> $DENY_CONF && \
        reload_nginx && \
        rep_info "add $1 to deny_list success.`date +"%Y-%m-%d %H:%M:%S"`" || \
        rep_error "add $1 to deny_list failed."
    else
        rep_error "$1 has been in deny list!"
    	
    fi
}
add_ip_new()
{
    pre_check $1
    if [[ $? -eq 0 ]];then
        sed -i "s/\")/|$1&/g" $DENY_CONF && \
        reload_nginx && \
        rep_info "add $1 to deny_list success." || \
        rep_error "add $1 to deny_list failed."
    else
        rep_error "$1 has been in deny list!"
        exit
    fi
}

#开始时间
start_time=`date -d"$last_minutes minutes ago" +"%H:%M:%S"`
#echo $start_time
#结束时间
stop_time=`date +"%H:%M:%S"`
#echo $stop_time
#过滤出单位之间内的日志并统计最高ip数
if [ $# == 0 ]
then
	echo Usage: $0 log_name1 log_name2 ...
else
	for I in $@
	do 
		tac $logfile/$I |grep -Ev "spider|robot|cj_fa.php|cj_com_sell.php|$WITE_IP"| awk -v st="$start_time" -v et="$stop_time" '{t=substr($5,RSTART+14,21);if(t>=st && t<=et) {print $0}}'| awk '{print $1}' | sort | uniq -c | sort -nr > $logfile/log_ip_top10_1
		#ip_top=`cat $logfile/log_ip_top10_1 | head -1 | awk '{print $1}'`
		ip=`cat $logfile/log_ip_top10_1 |grep -v "-"|awk '{if($1>2000)print $2}'`
		#此处可以选择封排名最高的ip，也可以选择按照访问量来封
		for A in $ip
		do
			add_ip_new  $A
		done
		tac $logfile/$I |grep -Ev "spider|robot|cj_fa.php|cj_com_sell.php|$WITE_IP"| awk -v st="$start_time" -v et="$stop_time" '{t=substr($5,RSTART+14,21);if(t>=st && t<=et) {print $0}}'| awk '{print $1}' |awk -F'.' '{print $1"."$2"."$3".*"}'| sort | uniq -c | sort -nr > $logfile/log_ip_top10_2
		ip_segment=`cat $logfile/log_ip_top10_2 |grep -v "-"|awk '{if($1>2000)print $2}'`
		for A in ${ip_segment}
		do
			add_ip_new $A
		done
	done		
fi

