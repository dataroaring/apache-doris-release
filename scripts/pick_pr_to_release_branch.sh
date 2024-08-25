AUTHOR=$1
BRANCH_LABEL=$2 
BRANCH=$3
DRY_RUN=$4

function pick_commit_to_branch() {
    COMMIT=$1
    BRANCH=$2
    PR=$3

    local current_branch=$(git branch --show-current)

    echo "Picking PR #$PR to $BRANCH"
    git fetch origin
    if [ "$DRY_RUN" == "false" ]; then
        echo "git checkout -b ${PR}_${BRANCH} origin/$BRANCH "
        git checkout -b ${PR}_${BRANCH} origin/$BRANCH || exit 1
        git cherry-pick $COMMIT || exit 1
        git push self ${PR}_${BRANCH}:${PR}_${BRANCH} --force || exit 1
        new_pr_number=$(gh pr create --base $BRANCH --head $AUTHOR:${PR}_${BRANCH} --fill --body "cherry-pick #$PR to $BRANCH" | awk '{print $NF}')
        echo "new PR: $new_pr_number"
        gh pr comment $new_pr_number --body "run buildall"
    else
        echo "gh pr create --base $BRANCH --head ${PR}_$BRANCH --body \"cherry-pick #$PR to $BRANCH\""
    fi

    git checkout $current_branch
}

gh pr list --author $AUTHOR --label $BRANCH_LABEL --state merged --base master --limit 100 --json  number,title,mergedAt,mergeCommit --jq '.[] | select(.mergedAt > (now - (3*86400)))' | while read -r pr; do
  # Extract the commit hash and PR number
  commit=$(echo "$pr" | jq -r '.mergeCommit.oid')
  number=$(echo "$pr" | jq -r '.number')
  title=$(echo "$pr" | jq -r '.title')

  # Check if the commit is already in the branch
  already_picked=$(gh pr list --state all --base $BRANCH --limit 500 --json number,title,body \
                    --jq ".[] | select(.title | contains(\"$number\")) | {number, title}" | wc -l)

  if [ $already_picked -gt 0 ]; then
    echo "PR #$number is already picked"
    continue
  fi

  echo "Picking PR #$number to $BRANCH titled: $title"
  pick_commit_to_branch $commit $BRANCH $number
done

