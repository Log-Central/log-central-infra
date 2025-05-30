#!/bin/sh
API="http://rabbit1:15672/api/queues"
AUTH="-u ${RABBITMQ_DEFAULT_USER}:${RABBITMQ_DEFAULT_PASS}"
SOCKET="/var/run/haproxy.sock"
QP_MAP="/etc/haproxy/queue_ports.map"
PMAP="/etc/haproxy/port_map.map"

# port_map 초기화
> "$PMAP"

while true; do
  # 1) 큐명→리더 호스트 추출
  curl -s $AUTH $API | jq -r '.[] | "\(.name) \(.leader|split("@")[0])"' > /tmp/leader.list

  # 2) 포트→서버ID(port_map) 생성
  #    queue_ports.map: 큐명→포트
  #    leader.list:     큐명→호스트(rabbit1|rabbit2|rabbit3)
  awk '
    BEGIN {
      # 큐명→포트
      while (getline < "'"$QP_MAP"'") > 0 {
        portOf[$1]=$2
      }
      close("'"$QP_MAP"'")
    }
    FNR==NR {
      # leader.list
      leaderOf[$1]=$2
      next
    }
    {
      # queue_ports.map
      q=$1; port=$2
      host=leaderOf[q]
      if (host != "") {
        # 서버ID는 "rabbit1","rabbit2" 등 hostname 그대로
        print port, host
      }
    }
  ' /tmp/leader.list "$QP_MAP" > "$PMAP"

  # 3) HAProxy에 맵 반영
  echo "set map /etc/haproxy/port_map.map" | socat stdio $SOCKET

  sleep 5
done
