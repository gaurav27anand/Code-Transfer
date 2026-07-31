#!/bin/bash

# Usage check
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <OWNER> <REPO> <PR_NUMBER>"
    echo "Example: $0 microsoft vscode 12345"
    exit 1
fi

OWNER=$1
REPO=$2
PR_NUMBER=$3

echo "===================================================="
echo "🕵️  STARTING GH PR AUDIT FOR $OWNER/$REPO/pull/$PR_NUMBER"
echo "===================================================="

# 1. Check current review states
echo -e "\n📋 CURRENT REVIEW STATUSES:"
gh api repos/$OWNER/$REPO/pulls/$PR_NUMBER/reviews \
  --jq '.[] | "- User: \(.user.login) | State: \(.state) | ID: \(.id)"' 2>/dev/null || echo "No reviews found."

# 2. Audit Timeline for Manual Dismissals
echo -e "\n🛑 MANUAL DISMISSAL LOGS (From PR Timeline):"
gh api repos/$OWNER/$REPO/issues/$PR_NUMBER/timeline \
  --jq '.[] | select(.event == "review_dismissed") | "- Review by \(.review_id) was DISMISSED by \(.actor.login) on \(.created_at) | Reason: \(.dismissal_message // "None provided")"' 2>/dev/null || echo "No manual dismissals found in timeline."

# 3. Check for Code Pushes (Potential Automatic Dismissals)
echo -e "\n🚀 CODE PUSH LOGS (May trigger automatic dismissal):"
gh api repos/$OWNER/$REPO/issues/$PR_NUMBER/timeline \
  --jq '.[] | select(.event == "committed") | "- New commit by \(.committer.name) on \(.committer.date): \(.message | split("\n")[0])"' 2>/dev/null || echo "No commits found in timeline."

# 4. General Branch Context
echo -e "\n🌿 PR BRANCH SUMMARY:"
gh pr view $PR_NUMBER --repo "$OWNER/$REPO" --json headRefName,baseRefName,state,author \
  --jq '"- Author: \(.author.login)\n- State: \(.state)\n- Branch: \(.headRefName) -> \(.baseRefName)"'

echo -e "\n===================================================="
echo "🎯 AUDIT COMPLETE"
echo "===================================================="
