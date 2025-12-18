#!/bin/bash

SONAR_HOST="https://v2code.rtwohealthcare.com"
PROJECT_KEY="Javaproject"
THRESHOLD=80

SONAR_TOKEN="${SONAR_TOKEN}"

echo "🔍 Fetching coverage..."

RESPONSE=$(curl -s -u ${SONAR_TOKEN}: \
"${SONAR_HOST}/api/measures/component?component=${PROJECT_KEY}&metricKeys=coverage")

COVERAGE=$(echo "$RESPONSE" | grep -oP '"value":"\K[^"]+')

if [ -z "$COVERAGE" ]; then
  echo "COVERAGE_STATUS=NULL"
  exit 2
fi

COVERAGE_INT=$(printf "%.0f" "$COVERAGE")
echo "COVERAGE=${COVERAGE_INT}"

if [ "$COVERAGE_INT" -lt "$THRESHOLD" ]; then
  echo "COVERAGE_STATUS=LOW"
  exit 1
fi

echo "COVERAGE_STATUS=OK"
exit 0
