#!/bin/bash

# check ssl expired date
# time 06/01/2019
# @TungPham

export LC_TIME=en_US.utf8

E_INVALID_DATE=-99
E_CAN_GET_SSL=-3
E_OK=0
E_OTHER=-1
E_EXP=-2
E_SELF_SIGN=-3

domain=$(<domainlist)
DOMAINS=($domain)
DOMAINS_COUNT=0

MY_MSG=""
TIME_STRING=$(date +%s)

NOTIFY_CRITICAL=15
NOTIFY_IS_CRITICAL=0
NOTIFY_IS_EXP=0

IS_TEST=0

# check is int
# $1 number
is_int()
{
    if [[ "$1" != [0-9]* ]]; then
        echo 0;
    else
        echo 1;
    fi
}

# check ssl
# $1 domain
check_ssl()
{
    curl --connect-timeout 30 -vIs https://$1 2>&1 | grep -i 'self signed certificate' > /dev/null
    if [ $? -eq 0 ]; then
        echo $E_SELF_SIGN
        return 0
    fi

    exp_date=$(curl --connect-timeout 30 -vIs https://$1 2>&1 -k | grep -i 'expire date' | sed 's/\*\s*expire date:\s//')

    exp_len=${#exp_date}
    if [ $exp_len -lt 5 ]; then
        echo $E_CAN_GET_SSL
        return 0
    fi

    exp_date=$(date -d "$exp_date" +%s)

    # is invalid date
    check_int=$(is_int "$exp_date")
    if [ $check_int -eq 0 ]; then
        echo $E_INVALID_DATE
        return 0
    fi

    # is expired
    remain_date=$[$exp_date-$TIME_STRING]
    [ $remain_date -le 0 ] && echo $E_EXP && return 0

    remain_day=$(($remain_date/86400))

    echo $remain_day
}

if [ -n "$1" ]; then 
    DOMAINS=($1)
    IS_TEST=1
fi

# run
for((i=0; i<${#DOMAINS[@]}; i++)); do
    domain=${DOMAINS[i]}
    return_code=$(check_ssl $domain)

    case $return_code in
        $E_INVALID_DATE )
            MY_MSG="$MY_MSG[EC] $domain: invalid date<br />"
            ;;
        $E_EXP )
            MY_MSG="‼ $MY_MSG[EC] $domain: expired date<br />"
            NOTIFY_IS_EXP=1
            DOMAINS_COUNT=$[$DOMAINS_COUNT+1]
            ;;
        $E_SELF_SIGN)
#            MY_MSG="$MY_MSG[FAP] $domain: Self Sign Certificate<br />"
            MY_MSG="$MY_MSG[FAP] $domain: invalid domain<br />"

            ;;
        $E_CAN_GET_SSL )
            MY_MSG="$MY_MSG[FAP] $domain: can not get SSL<br />"
            ;;
        $E_OTHER )
            MY_MSG="$MY_MSG[FAP] $domain: can not get info<br />"
            ;;
        * )
            # notify level    
            if [ $return_code -le $NOTIFY_CRITICAL ]; then
#                MY_MSG="$MY_MSG[<font color='red'> CRITICAL</font>] $domain $return_code days<br />"
                MY_MSG="$MY_MSG[CRITICAL] %e2%9a%a0 $domain $return_code days<br />"

                NOTIFY_IS_CRITICAL=1
                DOMAINS_COUNT=$[$DOMAINS_COUNT+1]
            #else
                #MY_MSG="$MY_MSG[WARNING] $domain $return_code days<br />"
            fi
            ;;
    esac
done

[ $IS_TEST -eq 1 -a -z "$2" ] && echo $MY_MSG && exit 0

title="[cron]"
[ $NOTIFY_IS_EXP -ne 0 ] && title="[EXPIRED]"
[ $NOTIFY_IS_CRITICAL -ne 0 ] && title="[CRITICAL]"

#curl_msg=$(echo "%e2%9a%a0 SSL CHECKER NOTIFICATION<br />"$MY_MSG | sed -r 's/<br \/>/\n/g' | sed -r 's/<[^>]*//g')
curl_msg=$(echo "<br />"$MY_MSG | sed -r 's/<br \/>/\n/g' | sed -r 's/<[^>]*//g')
#curl --connect-timeout 150 https://hoctapit.com/f0rw4rd -d group="Funtapcertmonitor" -d content="$curl_msg"

BOT_TOKEN=790943903:AAGomECAOTpUrxOSpXzHCfSQ8Zh5fr34m0U
CHANNEL_ID=-366158405
message="%e2%9A%A0"
curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage -d text="$curl_msg" -d chat_id=$CHANNEL_ID
