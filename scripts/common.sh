function get_pr_from_commit() {
    commit=$1
    pr=`git log --oneline $commit | grep $commit | awk '{print $NF}'`
    echo $pr
}

function is_pr_in_branch() {
    PR=$1
    BRANCH=$2

    git --no-pager log --oneline $BRANCH | grep "$PR" || return 1
}

function is_commit_in_branch() {
    COMMIT=$1
    BRANCH=$2

    PR=`get_pr_from_commit $COMMIT`
    if [ -z "$PR" ]; then
        echo "commit $COMMIT is not a PR"
        return 1
    fi

    is_pr_in_branch "$PR" "$BRANCH"
}
