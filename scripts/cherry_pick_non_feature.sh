# Description: cherry pick non-feature commits from 3.0 to 3.1
# Usage: bash cherry_pick_non_feature.sh

source common.sh

COMMITS=`grep -iv  "\[feature\]" commit_not_in_3.0 | grep -v "\[feat\]" | grep "PRS" | awk '{print $2}' | grep -v ignoring | grep -v pipeline`

handled=0
for COMMIT in $COMMITS; do
    echo "try to pick $COMMIT $handled"
    handled=$((handled+1))
    grep $COMMIT ignored_pr_by_3.0.txt && continue
    grep $COMMIT conflict_3.0_commits.txt && continue

    if is_commit_in_branch $COMMIT "branch-3.0"; then
        echo "$COMMIT is in branch-3.0"
        continue
    fi

    git cherry-pick $COMMIT
    if [ $? -ne 0 ]; then
        git cherry-pick --abort
        echo "failed to pick $COMMIT"
        echo $COMMIT >> conflict_new_commits.txt
        continue
    fi
    echo "picked $COMMIT $handled"
done

