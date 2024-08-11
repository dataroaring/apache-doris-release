source common.sh

DRY_RUN="false"

for COMMIT in `cat conflict_new_commits.txt`; do
    PR=`get_pr_from_commit $COMMIT`
    if [ -z "$PR" ]; then
        echo "commit $COMMIT is not a PR"
        continue
    fi

    if [ $DRY_RUN != "false" ]; then
        echo "dry run: add label dev/3.0.x-conflict to PR $PR"
        continue
    fi

    PR=`echo $PR | sed 's/#//' | sed 's/(//' | sed 's/)//'`
    echo "add label dev/3.0.x-conflict to PR $PR"
    gh pr edit $PR --add-label "dev/3.0.x-conflict"

done