#!/usr/bin/env bash
# 사용법: check_leader.sh <QUEUE_NAME>
QUEUE="$1"
NODE_HOST="$2"  # HAProxy가 검사 대상 노드 호스트명(rabbit1/rabbit2/…)을 넘겨줌

# RabbitMQ Management HTTP API 엔드포인트 (vhost ‘/’ 고정)
API="http://$NODE_HOST:15672/api/queues/%2F/$QUEUE"

# guest:guest 관리자 계정 사용
resp=$(curl -s -u guest:guest "$API")

# .leader 필드 추출
leader=$(echo "$resp" | jq -r '.leader')

# 현재 검사 중인 노드가 leader면 정상(0), 아니면 장애(1)
if [[ "$leader" == *"$NODE_HOST"* ]]; then
  exit 0
else
  exit 1
fi
