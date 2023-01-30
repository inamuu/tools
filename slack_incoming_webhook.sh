#!/bin/bash

#!/bin/bash

set -eu

MSG=$1

post_data()
{


  cat <<EOF
{
    "blocks": [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*${MSG}*"
            }
         }
    ]
}
EOF
}

curl -i -H "Content-type: application/json" -s -S -X POST -d "$(post_data)" "${SLACK_INCOMING_WEBHOOK}"

