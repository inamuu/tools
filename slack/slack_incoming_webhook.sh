#!/bin/bash

set -eu

MSG=${1:-"command success"}

post_data()
{
cat <<EOT
{
  "blocks": [
      {
          "type": "header",
          "text": {
              "type": "plain_text",
              "text": "New request",
              "emoji": true
           }
      }
  ],
  "attachments": [
    {
      "color": "#008000",
      "fields": [
          {
              "title": "A field's title",
              "value": "This field's value",
              "short": false
          },
          {
              "title": "A short field's title",
              "value": "A short field's value",
              "short": true
          },
          {
              "title": "A second short field's title",
              "value": "A second short field's value",
              "short": true
          }
      ]
    }
  ]
}
EOT
}

curl -i -H "Content-type: application/json" -s -S -X POST -d "$(post_data)" "${SLACK_INCOMING_WEBHOOK}"

