#!/bin/bash

# ------------- CONFIG -----------------
SONAR_HOST="https://v2code.rtwohealthcare.com"
PROJECT_KEY="Javaproject"
THRESHOLD=80

MAIL_TO="sathwikag12@gmail.com"

# Token comes from Jenkins environment
SONAR_TOKEN="${SONAR_TOKEN}"
# -------------------------------------

echo "🔍 Fetching code coverage from SonarQube..."

RESPONSE=$(curl -s -u ${SONAR_TOKEN}: \
"${SONAR_HOST}/api/measures/component?component=${PROJECT_KEY}&metricKeys=coverage")

COVERAGE=$(echo "$RESPONSE" | grep -oP '"value":"\K[^"]+')

SONAR_DASHBOARD="${SONAR_HOST}/dashboard?id=${PROJECT_KEY}"

# ---------------- NULL CHECK ----------------
if [ -z "$COVERAGE" ]; then
  echo "❌ Coverage is NULL or not reported"

  mail -a "Content-Type: text/html" \
  -s "❌ SonarQube Coverage MISSING - ${PROJECT_KEY}" \
  "$MAIL_TO" <<EOF
<html>
<body style="font-family: Arial;">
<h2 style="color:red;">Coverage Not Available ❌</h2>

<p><b>Project:</b> ${PROJECT_KEY}</p>
<p><b>Reason:</b> No coverage data reported to SonarQube.</p>

<p>Possible causes:</p>
<ul>
<li>No unit tests</li>
<li>JaCoCo not configured</li>
<li>Coverage report not generated</li>
</ul>

<p>
<a href="${SONAR_DASHBOARD}">View SonarQube Dashboard</a>
</p>

<p><b>Pipeline stopped.</b></p>
</body>
</html>
EOF

  exit 1   # 🚨 STOP JENKINS
fi

# ------------- COVERAGE CHECK -------------
COVERAGE_INT=$(printf "%.0f" "$COVERAGE")

echo "📊 Code Coverage: ${COVERAGE_INT}%"

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
<th>Dashboard</th>
<td><a href="${SONAR_DASHBOARD}">View SonarQube Report</a></td>
</tr>
</table>

<p><b>Pipeline stopped due to low coverage.</b></p>
</body>
</html>
EOF

  echo "❌ Coverage below threshold. Stopping pipeline."
  exit 1   # 🚨 STOP JENKINS
fi

# ---------------- SUCCESS ----------------
echo "✅ Coverage meets threshold (${THRESHOLD}%). Pipeline continues."
exit 0
