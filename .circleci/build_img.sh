set -x
$(aws ecr get-login --no-include-email --region us-east-1)
docker build -t aws-cli ../Docker/SimpleApp/
docker tag aws-cli:latest 020046395185.dkr.ecr.us-east-1.amazonaws.com/aws-cli:latest
# docker push 020046395185.dkr.ecr.us-east-1.amazonaws.com/aws-cli:latest