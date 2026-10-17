# Yashika_EWB_VPC_Peering (convert this file to PDF for submission)

Yashika / EWB VPC Peering 

## 1. Architecture and inventory
Diagram + table with actual resource IDs and private IPs (see README).

## 2. Subnets and route tables
Screenshots: subnet CIDRs; ewb-rt-a-public, ewb-rt-a-private, ewb-rt-b-private with subnet associations.
(Checkpoints 01 and 04)

## 3. Peering
Screenshot: ewb-a-b-peer Active, both VPC IDs (Checkpoint 03).

## 4. Security groups
Screenshot of inbound rules for each of the three groups.

## 5. Instances
Screenshot: IDs, private IPs, bastion public IP, empty public IPv4 for App-A/App-B (Checkpoint 02).

## 6. Test evidence (label each screenshot: host / test / result)
- 01 Baseline failure
- 02 and 03 Forward and reverse ping
- 04 SSH to App-B through bastion
- 05 Isolation: no public IPv4
- 06 and 07 Controlled ICMP failure and recovery + short explanation

## 7. Forward path and return path explanation

## 8. Cleanup evidence and what I learned

> Do NOT include private keys, passwords or tokens.
