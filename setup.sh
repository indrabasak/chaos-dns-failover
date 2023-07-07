#!/usr/local/bin/bash

DOMAIN_NAME="demo.com"
SUB_DOMAIN_NAME="chaos.demo.com"
LS_HOSTED_ZONE_ID=''
LS_CERT_ARN=''
REGION_US_WEST_2="us-west-2"
REGION_US_EAST_1="us-east-1"

usage() {
    echo "<deploylocal|test>"
}

createLocalHostedZone(domainName) {
  echo "Route53: Creating domain: $domainName"
  local response=$(awslocal route53 create-hosted-zone --name $domainName --caller-reference r53-hz-$domainName --hosted-zone-config Comment="project:$domainName" --output json)
  echo "response while creating custom domain: $response"
  local hostedZoneId=$(echo $response | jq .HostedZone.Id | sed -r 's/"\/hostedzone\/(.*)"/\1/g')
  echo "hosted zone id is $hostedZoneId"
}

createLocalCertificate(region, subDomainName) {
  echo "ACM: Creating Certificate"
  local response=$(awslocal acm request-certificate --region $region --domain-name $subDomainName --validation-method DNS --subject-alternative-names *.$subDomainName --tags Key=project,Value=$subDomainName --output json)
  local certArn=$(echo $response | jq -r .CertificateArn)
  echo "Cert ARN is $certArn"
}

if [ "$1" = "deploylocal" ]; then
    echo "local deploy started"
    initLocalstack
    createLocalHostedZone($DOMAIN_NAME)
    createLocalCertificate($REGION_US_WEST_2, $SUB_DOMAIN_NAME)
    createLocalCertificate($REGION_US_EAST_1, $SUB_DOMAIN_NAME)

    terraformDeployLocal
    serverlessDeployLocal
    echo "local deploy completed"
else
    echo "Incorrect arguments passed"
    usage
fi

exit
