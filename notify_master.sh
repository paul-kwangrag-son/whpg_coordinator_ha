#!/bin/bash
# /etc/keepalived/notify_master.sh

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)
CURRENT_STATE="$1"    # notify 스크립트로 전달되는 세 번째 인자 (MASTER, BACKUP, FAULT)

logger "$TIMESTAMP INFO: [$HOSTNAME] Keepalived State changed to $CURRENT_STATE by notify_master.sh"

if [ "$CURRENT_STATE" == "MASTER" ]; then
    logger "$TIMESTAMP INFO: [$HOSTNAME] Keepalived This node is now MASTER. Starting WHPG..."
    # 예시: 웹 서비스 시작 명령어
    # sudo /usr/bin/systemctl start my_service.service
    export COORDINATOR_DATA_DIRECTORY=/data/master/gpseg-1
    sudo -u gpadmin -i gpactivatestandby -f -d $COORDINATOR_DATA_DIRECTORY -q -a

    SERVICE_START_STATUS=$?

    if [ $SERVICE_START_STATUS -eq 0 ]; then
        logger "$TIMESTAMP SUCCESS: [$HOSTNAME] Keepalived WHPG started successfully."
    else
        logger "$TIMESTAMP ERROR: [$HOSTNAME] Keepalived Failed to start WHPG (Exit Code: $SERVICE_START_STATUS)."
        # 서비스 시작 실패 시 추가 조치 (예: 긴급 알림)
        # logger "ERROR: Service start failed on $HOSTNAME during failover!" | mail -s "Keepalived Critical Alert" admin@example.com
    fi

    # 예시: 가상 IP로의 연결 확인
    # ping -c 1 192.168.1.100 > /dev/null
    # if [ $? -eq 0 ]; then
    #     echo "$TIMESTAMP INFO: [$HOSTNAME - $VRRP_INSTANCE_NAME] VIP 192.168.1.100 is reachable." >> "$LOG_FILE"
    # else
    #     echo "$TIMESTAMP ERROR: [$HOSTNAME - $VRRP_INSTANCE_NAME] VIP 192.168.1.100 is NOT reachable." >> "$LOG_FILE"
    # fi

else # BACKUP 또는 FAULT 상태일 때의 notify_master 스크립트 실행 (notify 스크립트 사용 시)
    logger "$TIMESTAMP INFO: [$HOSTNAME] Keepalived Executing notify_master.sh in $CURRENT_STATE state, no action taken."
fi

exit 0
