ROOT="./Docker/SimpleApp" 
REPOSITORY_TYPE="github"
CIRCLE_API="https://circleci.com/api"

############################################
## 1. Commit SHA of last CI build
############################################
LAST_COMPLETED_BUILD_URL="${CIRCLE_API}/v1.1/project/${REPOSITORY_TYPE}/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/tree/${CIRCLE_BRANCH}?filter=completed&limit=100&shallow=true"
echo $LAST_COMPLETED_BUILD_URL
LAST_COMPLETED_BUILD_SHA=`curl -Ss -u "${CIRCLE_TOKEN}:" "${LAST_COMPLETED_BUILD_URL}" | jq -r 'map(select(.status == "success") | select(.workflows.workflow_name != "ci")) | .[0]["vcs_revision"]'`
echo $LAST_COMPLETED_BUILD_SHA

if  [[ ${LAST_COMPLETED_BUILD_SHA} == "null" ]]; then
  echo -e "\e[93mThere are no completed CI builds in branch ${CIRCLE_BRANCH}.\e[0m"

  TREE=$(git show-branch -a \
    | grep '\*' \
    | grep -v `git rev-parse --abbrev-ref HEAD` \
    | sed 's/.*\[\(.*\)\].*/\1/' \
    | sed 's/[\^~].*//' \
    | uniq)

  REMOTE_BRANCHES=$(git branch -r | sed 's/\s*origin\///' | tr '\n' ' ')
  PARENT_BRANCH=master
  for BRANCH in ${TREE[@]}
  do
    BRANCH=${BRANCH#"origin/"}
    if [[ " ${REMOTE_BRANCHES[@]} " == *" ${BRANCH} "* ]]; then
        echo "Found the parent branch: ${CIRCLE_BRANCH}..${BRANCH}"
        PARENT_BRANCH=$BRANCH
        break
    fi
  done

  echo "Searching for CI builds in branch '${PARENT_BRANCH}' ..."

  LAST_COMPLETED_BUILD_URL="${CIRCLE_API}/v1.1/project/${REPOSITORY_TYPE}/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/tree/${PARENT_BRANCH}?filter=completed&limit=100&shallow=true"
  LAST_COMPLETED_BUILD_SHA=`curl -Ss -u "${CIRCLE_TOKEN}:" "${LAST_COMPLETED_BUILD_URL}" \
    | jq -r "map(\
      select(.status == \"success\") | select(.workflows.workflow_name != \"ci\") | select(.build_num < ${CIRCLE_BUILD_NUM})) \
    | .[0][\"vcs_revision\"]"`
fi

if [[ ${LAST_COMPLETED_BUILD_SHA} == "null" ]]; then
  echo -e "\e[93mNo CI builds for branch ${PARENT_BRANCH}. Using master.\e[0m"
  LAST_COMPLETED_BUILD_SHA=master
fi

############################################
## 2. Changed packages
############################################
PACKAGES=$(ls ${ROOT} -l | awk '{print $9}')
echo "Searching for changes since commit [${LAST_COMPLETED_BUILD_SHA:0:7}] ..."


PARAMETERS='"trigger":false'
COUNT=0
for PACKAGE in ${PACKAGES[@]}
do
  PACKAGE_PATH=${ROOT#.}/$PACKAGE
  LATEST_COMMIT_SINCE_LAST_BUILD=$(git log -1 $CIRCLE_SHA1 ^$LAST_COMPLETED_BUILD_SHA --format=format:%H --full-diff ${PACKAGE_PATH#/})

  if [[ -z "$LATEST_COMMIT_SINCE_LAST_BUILD" ]]; then
    echo -e "\e[90m  [-] $PACKAGE \e[0m"
    if [[ $PACKAGE == "requirements.txt" ]]; then
      checksum=$(git log -n 1 --pretty=format:%H -- ${PACKAGE_PATH#/})
      SHORT_GIT_HASH=$(echo $checksum | cut -c -7)
      echo -e "${SHORT_GIT_HASH}" > .circleci/checksum
    fi
  else
    if [[ $PACKAGE == "requirements.txt" ]]; then
        PARAMETERS+=", \"requirements\":true"
        COUNT=$((COUNT + 1))
        echo -e "\e[36m  [+] ${PACKAGE} \e[21m (changed in [${LATEST_COMMIT_SINCE_LAST_BUILD:0:7}])\e[0m"
        echo "${LATEST_COMMIT_SINCE_LAST_BUILD:0:7}" > .circleci/checksum
    else
        COUNT=$((COUNT + 1))
        echo -e "\e[36m  [+] ${PACKAGE} \e[21m (changed in [${LATEST_COMMIT_SINCE_LAST_BUILD:0:7}])\e[0m"
    fi
  fi
done

if [[ $COUNT -eq 0 ]]; then
  echo -e "\e[93mNo changes detected in packages. Skip triggering workflows.\e[0m"
  exit 0
fi

echo "Changes detected in ${COUNT} package(s)."