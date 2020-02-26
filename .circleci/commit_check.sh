set -e

# latest commit
LATEST_COMMIT=$(git rev-parse HEAD)

# latest commit where path/to/folder1 was changed
FOLDER1_COMMIT=$(git log -1 --format=format:%H --full-diff Docker/SimpleApp/requirements.txt)

# latest commit where path/to/folder2 was changed
# FOLDER2_COMMIT=$(git log -1 --format=format:%H --full-diff path/to/folder2)

if [ $FOLDER1_COMMIT = $LATEST_COMMIT ];
    then
        echo "requirements have changed"
        exit 0;
# elif [ $FOLDER2_COMMIT = $LATEST_COMMIT ];
#     then
#         echo "files in folder2 has changed"
else
     echo "no folders of relevance has changed"
     exit 1;
fi
