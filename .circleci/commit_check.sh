ROOT="./Docker/SimpleApp" 
PACKAGES=$(ls ${ROOT} -l | awk '{print $9}')
for PACKAGE in ${PACKAGES[@]}
do
  PACKAGE_PATH=${ROOT#.}/$PACKAGE
  if [[ $PACKAGE == "requirements.txt" ]]; then
    checksum=$(git log -n 1 --pretty=format:%H -- ${PACKAGE_PATH#/})
    SHORT_GIT_HASH=$(echo $checksum | cut -c -7)
    echo -e "${SHORT_GIT_HASH}" > .circleci/checksum
  fi
done