set -x

echo "Building Image -ECR Login"
$(aws ecr get-login --no-include-email --region us-east-1)
echo "Building Image -Building"
docker build -t aws-cli Docker/SimpleApp/
echo "Building Image -Tagging"
docker tag aws-cli:latest 020046395185.dkr.ecr.us-east-1.amazonaws.com/aws-cli:$LAST_COMPLETED_BUILD_SHA
# docker push 020046395185.dkr.ecr.us-east-1.amazonaws.com/aws-cli:latest