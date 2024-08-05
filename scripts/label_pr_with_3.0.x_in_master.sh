TARGET_BRANCH="origin/branch-3.0"
LAST_LABEL="dev/3.0.0-merged"
NEW_LABEL="dev/3.0.1-merged"
LAST_TAG="3.0.0-rc11"
DRY_RUN="false"

TAG_HASH=`git rev-list -n 1 $LAST_TAG`
PRS_IN_MASTER=`git log --since="2024-01-01" --reverse --oneline origin/master | awk '{print $NF}' | grep "(" | cut -c 2- | rev | cut -c 2- | rev`

function get_target_label() {
    PR=$1
    MATCH_MSG=`git --no-pager log $TARGET_BRANCH --oneline | grep "$PR)"`
    MATCH_MSG_LINES=`echo $MATCH_MSG | grep "$PR)" | wc -l`

    if [ ${MATCH_MSG_LINES} -eq 1 ]; then
        COMMIT_HASH=`echo $MATCH_MSG | awk '{print $1}'`
        git merge-base --is-ancestor $COMMIT_HASH $TAG_HASH
        IS_ANCESTOR=$?
        echo "COMMIT_HASH: $COMMIT_HASH TAG_HASH: $TAG_HASH"
        if [ ${IS_ANCESTOR} -eq 1 ]; then
            echo $NEW_LABEL
        elif [ ${IS_ANCESTOR} -eq 0 ]; then
            echo $LAST_LABEL
        else
            echo ""
        fi
    fi
}

for PR in ${PRS_IN_MASTER}; do
    TARGET_LABEL=`get_target_label $PR | tail -1`
    if [ -z "$TARGET_LABEL" ]; then
        echo "$PR is not in $TARGET_BRANCH"
        continue
    fi
    echo "label $PR with $TARGET_LABEL"
    if [ ${DRY_RUN} == "false" ]; then
        gh pr edit $PR --remove-label "dev/3.0.x" --add-label $TARGET_LABEL
    fi
done