#!/bin/bash

set -eu

MSG=${1:-"command success"}

post_data()
{
cat <<EOT
{
  "text": "Slack Notify",
  "blocks": [],
  "attachments": [
    {
      "color": "#008000",
      "blocks": [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*Result:* ${MSG}"
          }
        }
      ],
    }
  ]
}
EOT

}

curl -i -H "Content-type: application/json" -s -S -X POST -d "$(post_data)" "${SLACK_INCOMING_WEBHOOK}"

