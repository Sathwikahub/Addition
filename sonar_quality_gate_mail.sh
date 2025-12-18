#!/bin/bash

# -------- CONFIG --------
SONAR_HOST="https://v2code.rtwohealthcare.com"
PROJECT_KEY="Javaproject"
THRESHOLD=80

MAIL_TO="sathwikag12@gmail.com"

# Token must come from Jenkins environment
SONAR_TOKEN="${SONAR_TOKEN}"
# ------------------------

echo "🔍 Fetching coverage from SonarQube..."

RESPONSE=$(curl -s -u ${SONAR_TOKEN}: \
"${SONAR_HOST}/api/measures/component?component=${PROJECT_KEY}&metricKeys=coverage")

COVERAGE=$(echo "$RESPONSE" | grep -oP '"value":"\K[^"]+')

SONAR_DASHBOARD="${SONAR_HOST}/dashboard?id=${PROJECT_KEY}"

# If coverage not found → fail pipeline
if [ -z "$COVERAGE" ]; then
  echo "❌ Unable to fetch coverage from SonarQube"
  echo "$RESPONSE"
  exit 1
fi

COVERAGE_INT=$(printf "%.0f" "$COVERAGE")

echo "📊 SonarQube Coverage: ${COVERAGE_INT}%"

if [ "$COVERAGE_INT" -lt "$THRESHOLD" ]; then

mail -a "Content-Type: text/html" \
-s "❌ Code Coverage Below ${THRESHOLD}% - ${PROJECT_KEY}" \
"$MAIL_TO" <<EOF
<html>
<body style="font-family: Arial;">
<h2 style="color:red;">Code Coverage Failed ❌</h2>

<table border="1" cellpadding="8">
<tr><th>Project</th><td>${PROJECT_KEY}</td></tr>
<tr><th>Coverage</th><td style="color:red;">${COVERAGE_INT}%</td></tr>
<tr><th>Required</th><td>${THRESHOLD}%</td></tr>
<tr>
<th>Sonar Dashboard</th>
<td><a href="${SONAR_DASHBOARD}">View Report</a></td>
</tr>
</table>

<p><b>Pipeline stopped due to low coverage.</b></p>
</body>
</html>
EOF

  echo "❌ Coverage below threshold. Stopping pipeline."
  exit 1   # 🚨 STOP JENKINS PIPELINE
fi

echo "✅ Coverage meets threshold. Continuing pipeline."
exit 0
