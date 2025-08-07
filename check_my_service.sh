#!/bin/bash
# /etc/keepalived/check_my_service.sh

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)

# DB 접속 정보 설정
# 필요한 경우 환경 변수 또는 직접 지정 (예: -h 호스트 -p 포트 -U 사용자)
DB_HOST="whpg-m"     # 호스트 (또는 IP 주소)
DB_PORT="5432"       # 포트
DB_USER="gpadmin"    # 접속할 사용자 (권한이 있는 사용자)

#logger "$TIMESTAMP INFO: [$HOSTNAME] Keepalived starting check WHPG Status" 

# pg_isready 명령 실행
RETURN=`/usr/local/greenplum-db/bin/pg_isready -h "$DB_HOST" -d postgres -p "$DB_PORT" -U "$DB_USER" -t 1`
ROLE=$(echo "$RETURN" | awk '{print $NF}')
/usr/local/greenplum-db/bin/pg_isready -h "$DB_HOST" -d postgres -p "$DB_PORT" -U "$DB_USER" -t 1 -q

# pg_isready의 종료 코드 확인
# 0 :  마스터로서 정상 상태임          whpg-m:5432 - accepting connections
# 64 : Standny 마스터로서 정상 상태임  whpg-sm:5432 - mirror ready
# 1 : 서버가 연결을 거부함 (시작 중이거나, pg_hba.conf 문제 등)
# 2 : 응답 없음 (서버 다운 또는 네트워크 문제)
# 3 : 잘못된 인수 (오류)                     whpg-m0:5432 - no attempt

RETURN_CODE=$?
if [[ $ROLE = "connections" && $RETURN_CODE -eq 0 ]]; then
  #logger "$TIMESTAMP INFO: Keepalived $ROLE $RETURN_CODE 0"
  exit 0
#elif [[ $ROLE = "ready" && $RETURN_CODE -eq 64 ]]; then
#  #logger "$TIMESTAMP INFO: Keepalived $ROLE $RETURN_CODE 0" 
#  exit 0
else
  #logger "$TIMESTAMP ERROR: Keepalived $ROLE $RETURN_CODE 1"
  exit 1
fi

#logger "$TIMESTAMP INFO: [$HOSTNAME] Keepalived completed checking WHPG Status" 
