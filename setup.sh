#!/usr/local/bin/bash

LOCALSTACK_HOSTNAME="localhost"
EDGE_PORT=4566

BASE_NAME="chaos-dns-failover"
DOMAIN_NAME="indra-sbx.autodesk.com"
SUB_DOMAIN_NAME="chaos-dns.indra-sbx.autodesk.com"
LS_HOSTED_ZONE_ID=''
LS_CERT_ARN=''
REGION_US_WEST_2="us-west-2"
REGION_US_EAST_1="us-east-1"
APP_NAME="chaos-dns-failover"

usage() {
    echo "<deploy|destroy|deploylocal|destroylocal|hello|test>"
}

#
# Deploys terraform infrastructure code remotely
# @param 1 - region, e.g., us-west-2, us-east-1
# @param 2 - environment, e.g., sbx
#
terraformDeploy() {
  echo "terraformDeploy - 1"
  export TF_LOG=DEBUG

  local bucketName=${BASE_NAME}-$2-$1

  echo "----- $bucketName"
  echo "^^^ ./tf/environments/$1/$2.tfvars"

  terraform init -var-file=./environments/$1/$2.tfvars
  bucketImportStatus=$(terraform import -var "key=${BASE_NAME}/$1/$2/terraform.tfstate" -var-file=./environments/$1/$2.tfvars aws_s3_bucket_public_access_block.terraform_state ${bucketName})
  echo "3 ------------------"
  echo $bucketImportStatus

  bucketPublicAccessBlockImportStatus=$(terraform import -var "key=${BASE_NAME}/$1/$2/terraform.tfstate" -var-file=./environments/$1/$2.tfvars aws_s3_bucket_public_access_block.terraform_state ${bucketName})
  echo "4 ------------------"
  echo $bucketPublicAccessBlockImportStatus

  if [[ -n $bucketImportStatus || -n $bucketPublicAccessBlockImportStatus ]]; then
    echo "The terraform S3 backend could not be imported, so one will now be created."

    terraformPlanOutputFile="$(pwd)/out-$1-$2.plan"
    echo ${terraformPlanOutputFile}
    echo "5 ------------------"
    terraform plan -var "key=${BASE_NAME}/$1/$2/terraform.tfstate" -var-file=./environments/$1/$2.tfvars -out="${terraformPlanOutputFile}"
    echo "6 ------------------"
    terraform apply -auto-approve -lock=true "${terraformPlanOutputFile}"
  else
    echo "An existing remote backend has been detected successfully."
    echo "Re-initializing using the detected remote backend."
  fi
}

#
# Deploys serverless application code remotely
#
serverlessDeploy() {
  echo "serverlessDeploy - started"
  sls deploy --stage $2 --region $1
  echo "serverlessDeploy - completed"
}

#
# Creates a local hosted zone
# @param 1 - domain name, e.g., indra-sbx.autodesk.com
#
createLocalHostedZone() {
  echo "Route53: Creating domain: $1"
  local response=$(awslocal route53 create-hosted-zone --name $1 --caller-reference r53-hz-$1 --hosted-zone-config Comment="project:$1" --output json)
  echo "response while creating custom domain: $response"
  local hostedZoneId=$(echo $response | jq .HostedZone.Id | sed -r 's/"\/hostedzone\/(.*)"/\1/g')
  echo "hosted zone id is $hostedZoneId"
}

initLocalstack() {
  echo "1 -------------"
  export LOCALSTACK_HOSTNAME="${LOCALSTACK_HOSTNAME}"
  echo $LOCALSTACK_HOSTNAME
  export EDGE_PORT="${EDGE_PORT}"
  echo $EDGE_PORT
  echo "2 -------------"
}

#
# Creates a local certificate
# @param 1 - region, e.g., us-west-2, us-east-1
# @param 2 - subDomain, e.g., chaos-dns.indra-sbx.autodesk.com
#
createLocalCertificate() {
  echo "ACM: Creating Certificate"
  local response=$(awslocal acm request-certificate --region $1 --domain-name $2 --validation-method DNS --subject-alternative-names *.$2 --tags Key=project,Value=$2 --output json)
  local certArn=$(echo $response | jq -r .CertificateArn)
  echo "Cert ARN is $certArn"
}

cleanup() {
  rm -rf terraform.tfstate
  rm -rf *.plan
}

#
# Deploys terraform infrastructure code remotely
# @param 1 - region, e.g., us-west-2, us-east-1
# @param 2 - environment, e.g., sbx
#
terraformDeployLocal() {
  echo "terraformDeployLocal - 1"
  export TF_LOG=DEBUG

  local bucketName=${BASE_NAME}-$2-$1

  echo "----- $bucketName"
  echo "^^^ ./tf/environments/$1/$2.tfvars"

  tflocal init -var-file=./environments/$1/$2.tfvars
  bucketImportStatus=$(tflocal import -var "key=${BASE_NAME}/$1/$2/terraform.tfstate" -var-file=./environments/$1/$2.tfvars aws_s3_bucket_public_access_block.terraform_state ${bucketName})
  echo "3 ------------------"
  echo $bucketImportStatus

  bucketPublicAccessBlockImportStatus=$(tflocal import -var "key=${BASE_NAME}/$1/$2/terraform.tfstate" -var-file=./environments/$1/$2.tfvars aws_s3_bucket_public_access_block.terraform_state ${bucketName})
  echo "4 ------------------"
  echo $bucketPublicAccessBlockImportStatus

  if [[ -n $bucketImportStatus || -n $bucketPublicAccessBlockImportStatus ]]; then
    echo "The terraform S3 backend could not be imported, so one will now be created."

    terraformPlanOutputFile="$(pwd)/out-$1-$2.plan"
    echo ${terraformPlanOutputFile}
    echo "5 ------------------"
    tflocal plan -var "key=${BASE_NAME}/$1/$2/terraform.tfstate" -var-file=./environments/$1/$2.tfvars -out="${terraformPlanOutputFile}"
    echo "6 ------------------"
    tflocal apply -auto-approve -lock=true "${terraformPlanOutputFile}"
  else
    echo "An existing remote backend has been detected successfully."
    echo "Re-initializing using the detected remote backend."
  fi
}

serverlessDeployLocal() {
  echo "serverlessDeployLocal - started"
  sls deploy --stage local --region $1
  echo "serverlessDeployLocal - completed"
}

if [ "$1" = "deploy" ]; then
    echo "deployment started"
#    terraformDeploy us-west-2 sbx
#    serverlessDeploy us-west-2 sbx
    terraformDeploy us-east-1 sbx
    serverlessDeploy us-east-1 sbx
    echo "deployment completed"
elif [ "$1" = "deploylocal" ]; then
    echo "local deploy started"
    initLocalstack
    createLocalHostedZone $DOMAIN_NAME
    createLocalCertificate $REGION_US_WEST_2 $SUB_DOMAIN_NAME
    createLocalCertificate $REGION_US_EAST_1 $SUB_DOMAIN_NAME

    cleanup
    terraformDeployLocal $REGION_US_WEST_2 sbx
    serverlessDeploy $REGION_US_WEST_2 local

    cleanup
    terraformDeployLocal $REGION_US_EAST_1 sbx
    serverlessDeploy $REGION_US_EAST_1 local
    echo "local deploy completed"
else
    echo "Incorrect arguments passed"
    usage
fi

exit
