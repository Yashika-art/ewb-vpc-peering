# AWS VPC Peering Project (EWB Cloud Labs - Project 01)

**Student:** YOUR NAME  **Batch:** YOUR BATCH  **Region:** ap-south-1 (Mumbai)  **Completed:** DD/MM/YYYY

Two private VPCs connected with VPC peering, with one public bastion in VPC A used for administration (SSH ProxyJump).

## Architecture

```
 Laptop --SSH/22--> Internet Gateway (ewb-igw-a)
                          |
 +------------------- VPC A 10.10.0.0/16 ------------+      +------ VPC B 10.20.0.0/16 ------+
 | Public  10.10.1.0/24  ewb-bastion  10.10.1.10     |      | Private 10.20.1.0/24           |
 | Private 10.10.2.0/24  ewb-app-a    10.10.2.10     |<====>| ewb-app-b 10.20.1.10 (no IGW)  |
 +---------------------------------------------------+ pcx  +--------------------------------+
```

| Resource | Name | CIDR / IP | Actual ID |
|---|---|---|---|
| VPC A | ewb-vpc-a | 10.10.0.0/16 | vpc-xxxx |
| Public subnet A | ewb-a-public | 10.10.1.0/24 | subnet-xxxx |
| Private subnet A | ewb-a-private | 10.10.2.0/24 | subnet-xxxx |
| VPC B | ewb-vpc-b | 10.20.0.0/16 | vpc-xxxx |
| Private subnet B | ewb-b-private | 10.20.1.0/24 | subnet-xxxx |
| Internet gateway | ewb-igw-a | - | igw-xxxx |
| Route tables | ewb-rt-a-public / ewb-rt-a-private / ewb-rt-b-private | - | rtb-xxxx |
| Security groups | ewb-sg-bastion / ewb-sg-app-a / ewb-sg-app-b | - | sg-xxxx |
| Bastion | ewb-bastion | 10.10.1.10 + public IPv4 | i-xxxx |
| App-A | ewb-app-a | 10.10.2.10 | i-xxxx |
| App-B | ewb-app-b | 10.20.1.10 | i-xxxx |
| Peering | ewb-a-b-peer | VPC A <-> VPC B | pcx-xxxx |

(Replace every `xxxx` with your real IDs - `terraform output` prints most of them.)

## Route tables

| Route table (subnet) | Destination | Target |
|---|---|---|
| ewb-rt-a-public (ewb-a-public) | 10.10.0.0/16 / 0.0.0.0/0 / 10.20.0.0/16 | local / igw / pcx |
| ewb-rt-a-private (ewb-a-private) | 10.10.0.0/16 / 10.20.0.0/16 | local / pcx |
| ewb-rt-b-private (ewb-b-private) | 10.20.0.0/16 / 10.10.0.0/16 | local / pcx |

## Security group inbound rules

| SG | Rule | Source |
|---|---|---|
| ewb-sg-bastion | SSH 22 | my public IP /32 |
| ewb-sg-app-a | SSH 22 | 10.10.1.10/32 |
| ewb-sg-app-a | ICMP echo request (type 8) | 10.20.1.10/32 |
| ewb-sg-app-b | SSH 22 | 10.10.1.10/32 |
| ewb-sg-app-b | ICMP echo request (type 8) | 10.10.2.10/32 |

## How to reproduce

You can follow the workbook in the AWS console, or use the Terraform in `terraform/` (same names, CIDRs, rules).

```bash
# 0. Prerequisites: AWS CLI configured for the lab account, Terraform >= 1.5
ssh-keygen -y -f ~/.ssh/ewb-lab.pem > ~/.ssh/ewb-lab.pub   # public key from your key (or create a new key pair)
chmod 400 ~/.ssh/ewb-lab.pem

cd terraform
cp terraform.tfvars.example terraform.tfvars   # edit name + public IP (curl -s https://checkip.amazonaws.com)

# Phase 1 - baseline: everything EXCEPT peering
terraform init && terraform apply              # enable_peering = false
# add the bastion IP (terraform output bastion_public_ip) to ~/.ssh/config using scripts/ssh_config.template
cd .. && ./scripts/run_tests.sh baseline       # expect 100% packet loss

# Phase 2 - peering + routes
cd terraform && terraform apply -var enable_peering=true
cd .. && ./scripts/run_tests.sh peered         # expect 0% loss both ways + shell on App-B

# Controlled failure (ICMP rule on ewb-sg-app-b)
./scripts/controlled_failure.sh remove         # ping from App-A -> fails
./scripts/controlled_failure.sh restore        # ping again -> works

# Cleanup (after saving evidence)
cd terraform && terraform destroy
```

## Test results (my own execution)

Fill in after running. Real output is saved in `evidence/`; screenshots go in `evidence/screenshots/`.

| Test | Result | Evidence |
|---|---|---|
| 01 Baseline (App-A -> App-B before peering) | _paste result_ | evidence/test01_baseline.txt |
| 02 Forward ping | _paste result_ | evidence/test02_forward.txt |
| 03 Reverse ping | _paste result_ | evidence/test03_reverse.txt |
| 04 Private SSH to App-B | _paste result_ | evidence/test04_ssh.txt |
| 05 No public IPv4 on App-A/App-B | _screenshot_ | evidence/screenshots/ |
| 06 ICMP rule removed -> failure | _paste result_ | evidence/screenshots/ |
| 07 ICMP rule restored -> recovery | _paste result_ | evidence/screenshots/ |

## Explanation: forward and return path

*Forward:* App-A (10.10.2.10) pings 10.20.1.10. `ewb-rt-a-private` sends 10.20.0.0/16 to the peering connection; `ewb-sg-app-b` allows ICMP echo from 10.10.2.10/32.
*Return:* App-B replies to 10.10.2.10. `ewb-rt-b-private` sends 10.10.0.0/16 to the peering connection. Security groups are stateful, so the reply is allowed automatically.
More in [docs/viva-answers.md](docs/viva-answers.md).

## What I learned

_Write 3-5 sentences in your own words._

## Cleanup

_Add screenshots showing no remaining instances, volumes, VPCs, peering connections or public IPv4 addresses (filter by tag Project = EWB-VPC-Peering)._
