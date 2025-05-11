# Log Management Infra

Docker Compose 기반의 Elasticsearch·Logstash·RabbitMQ·Grafana 인프라 구성

## 요구사항

- Docker & Docker Compose 설치
- Linux, macOS, Windows(WSL2) 환경 지원

## 서비스 기동

1. 프로젝트 루트에서 Compose 파일 확인

   ```bash
   ls docker-compose.yml
   ```

2. 컨테이너 빌드·시작

   ```bash
   docker-compose up -d
   ```

3. 상태 확인

   ```bash
   docker-compose ps
   ```

## 테스트

1. Elasticsearch 상태 확인

   ```bash
   curl -s -o /dev/null -w "%{http_code}" http://localhost:9200
   ```

2. 템플릿 로드 확인

   ```bash
   curl -s http://localhost:9200/_index_template/logs-default?pretty
   ```

3. 샘플 로그 색인

   ```bash
   curl -X POST http://localhost:9200/logs-$(date +%Y.%m.%d)/_doc/ \
     -H 'Content-Type: application/json' \
     -d '{ "@timestamp":"$(date -u +%Y-%m-%dT%H:%M:%SZ)", "message":"test", "level":"INFO", "user_field":"custom" }'
   ```

4. 검색 결과 확인

   ```bash
   curl -s 'http://localhost:9200/logs-*/_search?pretty&q=*'
   ```

5. Grafana 대시보드 접속

   - URL: [http://localhost:3000/d/sample_logs_dashboard](http://localhost:3000/d/sample_logs_dashboard)
   - ID/PW: admin/admin
