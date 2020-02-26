set -x
aws ecr get-login-password | docker login --username AWS --password-stdin 020046395185.dkr.ecr.us-east-1.amazonaws.com/aws-cli
docker build -t aws-cli ../Docker/SimpleApp/
docker tag aws-cli:latest 020046395185.dkr.ecr.us-east-1.amazonaws.com/aws-cli:latest
# docker push 020046395185.dkr.ecr.us-east-1.amazonaws.com/aws-cli:latest