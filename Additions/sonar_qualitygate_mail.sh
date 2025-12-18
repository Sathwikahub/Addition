#!/bin/bash

# ---------------- CONFIG ----------------
SONAR_HOST="https://v2code.rtwohealthcare.com"
PROJECT_KEY="Javaproject"
SONAR_TOKEN="sqp_66f750d999ef3b09e6eb1c9364831c0de05f03fa"

MAIL_TO="monish.reddy@invensis.net"

# ---------------------------------------

QG_STATUS=$(curl -s -u ${SONAR_TOKEN}: \
"${SONAR_HOST}/api/qualitygates/project_status?projectKey=${PROJECT_KEY}" \
| grep -oP '"status":"\K[^"]+')

COVERAGE=$(curl -s -u ${SONAR_TOKEN}: \
"${SONAR_HOST}/api/measures/component?component=${PROJECT_KEY}&metricKeys=coverage" \
| grep -oP '"value":"\K[^"]+')

SONAR_DASHBOARD="${SONAR_HOST}/dashboard?id=${PROJECT_KEY}"

if [ "$QG_STATUS" = "ERROR" ]; then

mail -a "Content-Type: text/html" \
-s "❌ SonarQube Quality Gate FAILED - ${PROJECT_KEY}" \
"$MAIL_TO" <<EOF
<html>
<body style="font-family: Arial, sans-serif;">
<h2 style="color:red;">SonarQube Quality Gate Failed ❌</h2>

<table border="1" cellpadding="8" cellspacing="0">
<tr><th align="left">Project</th><td>${PROJECT_KEY}</td></tr>
<tr><th align="left">Quality Gate</th><td style="color:red;">FAILED</td></tr>
<tr><th align="left">Coverage</th><td>${COVERAGE}%</td></tr>
<tr>
<th align="left">Dashboard</th>
<td><a href="${SONAR_DASHBOARD}">Open SonarQube</a></td>
</tr>
</table>
</body>
</html>
EOF

fi

exit 0

