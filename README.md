# cert-monitor
Monitor SSL certificate, push nortification to telegram

Add domain to domainlist file

## Edit check_ssl.sh

NOTIFY_CRITICAL=28 ###Expiry date of cert to alert

BOT_TOKEN=604821066:AAGVYbLdJRmHcjvxDW1wSrStKpAfWssssss ##Token of telegram bot

CHANNEL_ID=-1001367757187 ## Channel ID Telegram to receive Alert

## Create Telegram bot:
Chat with BotFather
## How to monitor
Set cronjob to execute check_ssl.sh

Eg: 0 9 * * * /bin/bash /path/to/file/check_ssl.sh
