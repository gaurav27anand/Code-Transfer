Here is the list of gh CLI commands you can use to investigate Pull Request states, history, timelines, and review changes.
## 1. gh api (The Deep Investigation)
This is the most powerful command because it fetches raw data from GitHub's backend that standard CLI commands hide.

* List PR Reviews: Finds dismissed, approved, or changes-requested statuses.

gh api repos/OWNER/REPO/pulls/PR_NUMBER/reviews

* View PR Timeline: Shows a chronological log of events, including exactly who dismissed a review and when.

gh api repos/OWNER/REPO/issues/PR_NUMBER/timeline

* Check Commit Statuses: See if automatic code pushes dismissed the reviews.

gh api repos/OWNER/REPO/commits/COMMIT_SHA/status


## 2. gh pr view (The Overview)
This command gives you a high-level summary of the PR directly in your terminal.

* View Review Summary: Shows the current overall review state (e.g., approved, merged, or blocked).

gh pr view PR_NUMBER

* Open in Browser: Quickly jumps to the web UI if you need to visually audit the conversation timeline.

gh pr view PR_NUMBER --web

[1, 2] 

## 3. gh pr diff (The Code Delta)
Use this to inspect if changes were made that might have triggered an automatic review dismissal. [3] 

* Examine Code Changes: View the raw diff of the PR.

gh pr diff PR_NUMBER

* Stat Summary: See how many lines changed across how many files.

gh pr diff PR_NUMBER --stat

[4] 

## 4. gh pr checkout (The Local Audit)
If you need to investigate the code locally on your machine.

* Pull Fork Branch: Safely clones and switches to the contributor's fork branch locally.

gh pr checkout PR_NUMBER

[5] 

If you want to automate this investigation, let me know:

* Would you like a bash script wrapper that combines these commands into a single audit report?
* Are you looking to track automatic dismissals (triggered by new code pushes) or manual dismissals (by administrators)?







## Other Commands:
gh api repos/OWNER/REPO/pulls/PR_NUMBER/reviews --jq '.[] | {user: .user.login, state: .state}'


gh api repos/OWNER/REPO/issues/PR_NUMBER/timeline --jq '.[] | select(.event == "reviewed" or .event == "committed") | {event: .event, author: (.user.login // .committer.name), date: (.submitted_at // .committer.date)}'


gh api repos/OWNER/REPO/issues/PR_NUMBER/timeline \
  --jq '.[] | select(.event == "review_dismissed") | "❌ REVIEW DISMISSED\n- Time: \(.created_at)\n- Dismissed By: \(.actor.login)\n- Dismissal Message: \(.dismissal_info.dismissal_message // "No reason provided")\n- Original Review State: \(.dismissal_info.review_id)"'
