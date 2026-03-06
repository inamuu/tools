#!/bin/bash

# Configuration
AWS_PROFILE="$1"
STATE_MACHINE_ARN="$2"
POLL_INTERVAL=60

# Function to notify via osascript
notify() {
    local status=$1
    local name=$2
    local message="Step Functions execution finished with status: $status"
    local execution_name=$(echo "$name" | awk -F: '{print $NF}')
    
    # Use osascript for macOS notification
    osascript -e "display notification "$message" with title "Step Functions" subtitle "$execution_name" sound name "Hero""
    
    # Also print to console
    echo "--------------------------------------------------"
    echo "NOTIFICATION SENT:"
    echo "Status: $status"
    echo "Execution: $execution_name"
    echo "--------------------------------------------------"
}

# Get latest execution ARN
get_latest_execution() {
    aws stepfunctions list-executions \
        --state-machine-arn "$STATE_MACHINE_ARN" \
        --max-items 1 \
        --profile "$AWS_PROFILE" \
        --query 'executions[0].executionArn' \
        --output text | head -n 1
}

# Get execution status
get_status() {
    local exec_arn=$1
    aws stepfunctions describe-execution \
        --execution-arn "$exec_arn" \
        --profile "$AWS_PROFILE" \
        --query 'status' \
        --output text | head -n 1
}

# Main
echo "Step Functions Monitoring Script"
echo "State Machine: $STATE_MACHINE_ARN"
echo "AWS Profile: $AWS_PROFILE"
echo "--------------------------------------------------"

if [ "$1" == "--start" ]; then
    echo "Starting a new execution..."
    EXEC_INFO=$(aws stepfunctions start-execution \
        --state-machine-arn "$STATE_MACHINE_ARN" \
        --profile "$AWS_PROFILE" \
        --query 'executionArn' \
        --output text | head -n 1)
    
    if [ $? -ne 0 ] || [ "$EXEC_INFO" == "None" ] || [ -z "$EXEC_INFO" ]; then
        echo "Failed to start execution."
        exit 1
    fi
    
    EXECUTION_ARN=$EXEC_INFO
    echo "Started: $EXECUTION_ARN"
else
    echo "Looking for the latest execution..."
    EXECUTION_ARN=$(get_latest_execution)
    
    if [ "$EXECUTION_ARN" == "None" ] || [ -z "$EXECUTION_ARN" ]; then
        echo "No executions found."
        exit 1
    fi
    echo "Found: $EXECUTION_ARN"
fi

STATUS=$(get_status "$EXECUTION_ARN")
echo "Current Status: $STATUS"

if [ "$STATUS" != "RUNNING" ] && [ -n "$STATUS" ] && [ "$STATUS" != "None" ]; then
    echo "The execution has already finished."
    notify "$STATUS" "$EXECUTION_ARN"
    exit 0
fi

echo "Monitoring... (polling every $POLL_INTERVAL seconds)"
echo "Press Ctrl+C to stop monitoring."

while true; do
    STATUS=$(get_status "$EXECUTION_ARN")
    
    if [ "$STATUS" != "RUNNING" ] && [ -n "$STATUS" ] && [ "$STATUS" != "None" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Execution finished with status: $STATUS"
        notify "$STATUS" "$EXECUTION_ARN"
        break
    fi
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Still running..."
    sleep "$POLL_INTERVAL"
done
