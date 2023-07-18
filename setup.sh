#!/usr/local/bin/bash

BASE_NAME="chaos-dns-failover"
DOMAIN_NAME="demo.com"
SUB_DOMAIN_NAME="chaos.demo.com"
LS_HOSTED_ZONE_ID=''
LS_CERT_ARN=''
REGION_US_WEST_2="us-west-2"
REGION_US_EAST_1="us-east-1"
APP_NAME="chaos-dns-failover"

usage() {
    echo "<deploy|destroy|deploylocal|destroylocal|hello|test>"
}

terraformDeploy() {
  echo "terraformDeploy - 1"
  export TF_LOG=DEBUG

  local bucketName=${BASE_NAME}-$2-$1

  echo "----- $bucketName"
  echo "^^^ ./tf/environments/$1/$2.tfvars"

  echo "1 ------------------"

  echo "2 ------------------"
  terraform init -var-file=./environments/$1/$2.tfvars
  bucketImportStatus=$(terraform import -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/$1/$2.tfvars aws_s3_bucket_public_access_block.terraform_state ${bucketName})
  echo "3 ------------------"
  echo $bucketImportStatus

  bucketPublicAccessBlockImportStatus=$(terraform import -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/$1/$2.tfvars aws_s3_bucket_public_access_block.terraform_state ${bucketName})
  echo "4 ------------------"
  echo $bucketPublicAccessBlockImportStatus

  if [[ -n $bucketImportStatus || -n $bucketPublicAccessBlockImportStatus ]]; then
    echo "The terraform S3 backend could not be imported, so one will now be created."

    terraformPlanOutputFile="$(pwd)/out-$1-$2.plan"
    echo ${terraformPlanOutputFile}
    echo "5 ------------------"
    terraform plan -var "key=${BASE_NAME}/terraform.tfstate" -var-file=./environments/$1/$2.tfvars -out="${terraformPlanOutputFile}"
    echo "6 ------------------"
    terraform apply -auto-approve -lock=true "${terraformPlanOutputFile}"
  else
    echo "An existing remote backend has been detected successfully."
    echo "Re-initializing using the detected remote backend."
  fi
}

serverlessDeploy() {
  echo "serverlessDeploy - started"
  sls deploy --stage $2 --region $1
  echo "serverlessDeploy - completed"
}

#createLocalHostedZone(domainName) {
#  echo "Route53: Creating domain: $domainName"
#  local response=$(awslocal route53 create-hosted-zone --name $domainName --caller-reference r53-hz-$domainName --hosted-zone-config Comment="project:$domainName" --output json)
#  echo "response while creating custom domain: $response"
#  local hostedZoneId=$(echo $response | jq .HostedZone.Id | sed -r 's/"\/hostedzone\/(.*)"/\1/g')
#  echo "hosted zone id is $hostedZoneId"
#}
#
#createLocalCertificate(region, subDomainName) {
#  echo "ACM: Creating Certificate"
#  local response=$(awslocal acm request-certificate --region $region --domain-name $subDomainName --validation-method DNS --subject-alternative-names *.$subDomainName --tags Key=project,Value=$subDomainName --output json)
#  local certArn=$(echo $response | jq -r .CertificateArn)
#  echo "Cert ARN is $certArn"
#}

if [ "$1" = "deploy" ]; then
    echo "deployment started"
#    terraformDeploy us-west-2 sbx
#    serverlessDeploy us-west-2 sbx
    terraformDeploy us-east-1 sbx
    serverlessDeploy us-east-1 sbx
    echo "deployment completed"
#elif [ "$1" = "deploylocal" ]; then
#    echo "local deploy started"
#    initLocalstack
#    createLocalHostedZone($DOMAIN_NAME)
#    createLocalCertificate($REGION_US_WEST_2, $SUB_DOMAIN_NAME)
#    createLocalCertificate($REGION_US_EAST_1, $SUB_DOMAIN_NAME)
#
#    terraformDeployLocal
#    serverlessDeployLocal
#    echo "local deploy completed"
else
    echo "Incorrect arguments passed"
    usage
fi

exit
