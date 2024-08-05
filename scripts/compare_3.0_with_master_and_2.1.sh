PRS_IN_MASTER=`git log --since="2024-01-01" --reverse --oneline origin/master | awk '{print $NF}' | grep "(" | cut -c 2- | rev | cut -c 2- | rev`

PRS_NOT_IN_21=()

for PR in ${PRS_IN_MASTER}; do
    MATCH_MSG_LINES=`git --no-pager log --oneline origin/branch-2.1 | grep "$PR)" | wc -l`
    if [ ${MATCH_MSG_LINES} -eq 0 ]; then
        PRS_NOT_IN_21+=("$PR")
    else
        PRS_IN_21+=("$PR")
    fi

    MATCH_MSG_LINES=`git --no-pager log --oneline origin/branch-3.0 | grep "$PR)" | wc -l`
    if [ ${MATCH_MSG_LINES} -eq 0 ]; then
        PRS_NOT_IN_30+=("$PR")
    else
        PRS_IN_30+=("$PR")
    fi
done

# echo array
for PR in "${PRS_NOT_IN_30[@]}"; do
    MATCH_MSG=`git --no-pager log --oneline origin/master | grep "$PR)"`
    echo "PRS_NOT_IN_30: ${MATCH_MSG}"
done

intersection=()
for element1 in "${PRS_NOT_IN_30[@]}"; do
    for element2 in "${PRS_IN_21[@]}"; do
        if [ "$element1" == "$element2" ]; then
            intersection+=("$element1")
            break
        fi
    done
done

for PR in "${intersection[@]}"; do
    MATCH_MSG=`git --no-pager log --oneline origin/master | grep "$PR)"`
    echo "PRS_NOT_IN_30_BUT_IN_21: ${MATCH_MSG}"
done