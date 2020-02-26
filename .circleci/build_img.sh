set -x

echo "Building Image -ECR Login"
$(aws ecr get-login --no-include-email --region us-east-1)
echo "Building Image -Building"
docker build -t simpleapp Docker/SimpleApp/
echo "Building Image -Tagging"
SHORT_GIT_HASH = $(echo $CIRCLE_SHA1 | cut -c -7)
docker tag simpleapp:latest 020046395185.dkr.ecr.us-east-1.amazonaws.com/simpleapp:${SHORT_GIT_HASH}
docker push 020046395185.dkr.ecr.us-east-1.amazonaws.com/simpleapp:${SHORT_GIT_HASH}