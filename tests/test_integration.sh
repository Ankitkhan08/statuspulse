#!/bin/bash
set -e

BASE_URL="${BASE_URL:-http://localhost:8000}"
PASS=0
FAIL=0

green() { echo -e "\033[32m✔ $1\033[0m"; }
red()   { echo -e "\033[31m✘ $1\033[0m"; }

check() {
  local desc="$1"
  local expected="$2"
  local actual="$3"
  if echo "$actual" | grep -q "$expected"; then
    green "$desc"
    PASS=$((PASS+1))
  else
    red "$desc (expected: $expected, got: $actual)"
    FAIL=$((FAIL+1))
  fi
}

echo "================================================"
echo " StatusPulse Integration Tests"
echo " Target: $BASE_URL"
echo "================================================"

# Test 1 — GET /health
echo ""
echo "--- GET /health ---"
RES=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/health")
check "GET /health returns 200" "200" "$RES"

BODY=$(curl -s "$BASE_URL/health")
check "GET /health has status field" "status" "$BODY"
check "GET /health api is healthy" "healthy" "$BODY"

# Test 2 — GET /
echo ""
echo "--- GET / ---"
RES=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/")
check "GET / returns 200" "200" "$RES"

BODY=$(curl -s "$BASE_URL/")
check "GET / has service field" "StatusPulse" "$BODY"

# Test 3 — POST /services
echo ""
echo "--- POST /services ---"
RES=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/services" \
  -H "Content-Type: application/json" \
  -d '{"name":"test-service","url":"http://example.com"}')
check "POST /services returns 200 or 201" "20" "$RES"

BODY=$(curl -s -X POST "$BASE_URL/services" \
  -H "Content-Type: application/json" \
  -d '{"name":"test-service-2","url":"http://example2.com"}')
check "POST /services returns id" "id" "$BODY"

# Test 4 — POST /services duplicate (409)
echo ""
echo "--- POST /services duplicate ---"
RES=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/services" \
  -H "Content-Type: application/json" \
  -d '{"name":"test-service","url":"http://example.com"}')
check "POST /services duplicate returns 409" "409" "$RES"

# Test 5 — GET /services
echo ""
echo "--- GET /services ---"
RES=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/services")
check "GET /services returns 200" "200" "$RES"

BODY=$(curl -s "$BASE_URL/services")
check "GET /services returns array" "test-service" "$BODY"

# Test 6 — POST /incidents
echo ""
echo "--- POST /incidents ---"
BODY=$(curl -s -X POST "$BASE_URL/incidents" \
  -H "Content-Type: application/json" \
  -d '{"service_name":"test-service","title":"Test Incident","description":"Testing","severity":"minor"}')
check "POST /incidents returns id" "id" "$BODY"
check "POST /incidents status is investigating" "investigating" "$BODY"

# Test 7 — GET /incidents
echo ""
echo "--- GET /incidents ---"
RES=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/incidents")
check "GET /incidents returns 200" "200" "$RES"

BODY=$(curl -s "$BASE_URL/incidents")
check "GET /incidents returns array with data" "Test Incident" "$BODY"

# Summary
echo ""
echo "================================================"
echo " Results: $PASS passed, $FAIL failed"
echo "================================================"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0