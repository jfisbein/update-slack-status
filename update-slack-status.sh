#!/usr/bin/env bash

set -euf -o pipefail

### REPLACE ALL THIS VARS WITH YOUR OWN VALUES
# how to get a token: https://api.slack.com/legacy/custom-integrations/legacy-tokens
SLACK_TOKEN="xoxp-123456789-123456789-123456789-123456789123456789"

declare -a AT_WORK_SSIDS=("MyOffice-Floor1" "MyOffice-Floor2" "MyOffice-Floor3")
declare -a AT_HOME_SSIDS=("MyHouse" "MyHouse-5Ghz")

AT_HOME_MESSAGE="Working remotely"
AT_HOME_EMOJI=":house_with_garden:"

AT_WORK_MESSAGE="Working from office"
AT_WORK_EMOJI=":office:"

WORK_END_TIME="19:00"
### END CONFIGURATION VARS

# Updates slack status
# param 1: Slack status text
# param 2: Slack status emoji
# param 3: Slack status expiration
function slack-update-status() {
    local TEXT="${1}"
    local EMOJI="${2}"
    local EXPIRATION="${3}"

    local DATA=$(printf '{"status_text":"%s","status_emoji":"%s","status_expiration":%s}' "${TEXT}" "${EMOJI}" "${EXPIRATION}")

    curl --silent --request POST https://slack.com/api/users.profile.set \
        --data-urlencode "profile=${DATA}" \
        --data-urlencode "token=${SLACK_TOKEN}"
}

# Resets slack status
function slack-reset-status() {
    local DATA='{"status_text":"","status_emoji":""}'

    curl --silent --request POST https://slack.com/api/users.profile.set \
        --data-urlencode "profile=${DATA}" \
        --data-urlencode "token=${SLACK_TOKEN}"
}

# Log message to syslog
# param 1: Message to log
function log() {
    logger --tag "slack-status" "$*"
}

# Check if a String is contined in a list of strings
# param 1: List of Strings space separated
# param 2: String to check
# returns: 0 if found, 1 otherwise.
function array-contains() {
    local ARRAY="${1}"
    local NEEDLE="${2}"

    for ELEMENT in $ARRAY; do
        if [[ "${ELEMENT}" = "${NEEDLE}" ]]; then
            return 0
        fi
    done

    return 1
}

# Main function
function main() {
    local SSID=$(iwgetid --raw)
    log "Connected to ${SSID}"
    if array-contains "${AT_WORK_SSIDS[*]}" "${SSID}"; then
        log "Setting WORK status"
        slack-update-status "${AT_WORK_MESSAGE}" "${AT_WORK_EMOJI}" $(date --date "$WORK_END_TIME today" +"%s") > /dev/null
    elif array-contains "${AT_HOME_SSIDS[*]}" "${SSID}"; then
        log "Setting HOME status"
        slack-update-status "${AT_HOME_MESSAGE}" "${AT_HOME_EMOJI}" $(date --date "$WORK_END_TIME today" +"%s") > /dev/null
    else
        log "Resetting status"
        slack-reset-status
    fi
}

main
