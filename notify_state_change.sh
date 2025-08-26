#!/bin/bash
# /etc/keepalived/notify_state_change.sh
# 모든 VRRP 상태 변화를 로깅하는 범용 스크립트

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)
CURRENT_STATE="$1" # MASTER, BACKUP, STOP

logger "$TIMESTAMP INFO: [$HOSTNAME] Keepalived state changed to $CURRENT_STATE by notify_state_change.sh"

# (옵션) 알림 추가
# if [ "$CURRENT_STATE" == "MASTER" ]; then
#   echo "Keepalived: MASTER on $HOSTNAME" | mail -s "HA Event" admin@example.com
# elif [ "$CURRENT_STATE" == "BACKUP" ]; then
#   echo "Keepalived: BACKUP on $HOSTNAME" | mail -s "HA Event" admin@example.com
# fi

exit 0
