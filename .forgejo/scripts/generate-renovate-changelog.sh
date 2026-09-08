#!/usr/bin/env bash

JSON_INPUT="$1"

# Check if jq is available to parse the JSON array of updates
echo "$JSON_INPUT" | jq -c '.[]' | while read -r update; do
    DEP_NAME=$(echo "$update" | jq -r '.depName')
    CURRENT_VERSION=$(echo "$update" | jq -r '.currentVersion // .currentValue')
    NEW_VERSION=$(echo "$update" | jq -r '.newVersion // .newValue')

    SAFE_NAME=$(echo "$DEP_NAME" | tr '/' '-')
    echo "Updated dependency $DEP_NAME: $CURRENT_VERSION -> $NEW_VERSION" > "changelog.d/$SAFE_NAME.feature.md"
done
