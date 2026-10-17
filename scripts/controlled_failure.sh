#!/usr/bin/env bash
# Controlled failure helper (Tests 06/07). Needs AWS CLI configured for your lab account.
# Easier alternative: edit ewb-sg-app-b inbound rules in the EC2 console.
# Usage: ./scripts/controlled_failure.sh remove | restore
set -eu
REGION="${AWS_REGION:-ap-south-1}"
SG_ID=$(aws ec2 describe-security-groups --region "$REGION" \
  --filters Name=group-name,Values=ewb-sg-app-b --query 'SecurityGroups[0].GroupId' --output text)
case "${1:-}" in
  remove)
    RULE_ID=$(aws ec2 describe-security-group-rules --region "$REGION" \
      --filters Name=group-id,Values="$SG_ID" \
      --query "SecurityGroupRules[?IsEgress==\`false\` && IpProtocol=='icmp'].SecurityGroupRuleId" --output text)
    aws ec2 revoke-security-group-ingress --region "$REGION" --group-id "$SG_ID" --security-group-rule-ids "$RULE_ID"
    echo "ICMP rule removed. From App-A run: ping -c 4 10.20.1.10 (expect 100% loss)" ;;
  restore)
    aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$SG_ID" \
      --ip-permissions 'IpProtocol=icmp,FromPort=8,ToPort=0,IpRanges=[{CidrIp=10.10.2.10/32,Description=ICMP echo request from App-A}]'
    echo "ICMP rule restored. Re-run the ping (expect replies)." ;;
  *) echo "usage: $0 remove|restore"; exit 1 ;;
esac
# This changes the rule outside Terraform; cleanup with 'terraform destroy' still works.
