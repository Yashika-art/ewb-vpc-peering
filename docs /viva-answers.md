# Viva preparation (understand these, then answer in your own words)

**1. Why is the return route needed?**
Peering only creates the link. A packet from App-A reaches App-B only if the source subnet has a route to 10.20.0.0/16 via the peering connection. App-B's reply to 10.10.2.10 also needs a route; without `10.10.0.0/16 -> pcx` in `ewb-rt-b-private` the reply has no path and the ping or SSH fails. Routing is not automatic or symmetric.

**2. Why is the App-B SSH source the bastion private IP?**
With ProxyJump, the laptop connects to the bastion, and the bastion opens a new SSH connection to App-B. App-B sees the connection coming from 10.10.1.10, not from your laptop's public IP. So `ewb-sg-app-b` must allow TCP 22 from 10.10.1.10/32. The public subnet also needs `10.20.0.0/16 -> pcx` so the bastion can reach VPC B.

**3. Why does Active peering not guarantee a successful ping?**
Active only means both VPCs accepted the connection. Traffic also needs routes in both subnets' route tables, security group rules allowing the traffic (ICMP echo request here), correct IPs, and, if used, network ACLs that allow it.

**4. Can VPC B use VPC A's internet gateway over peering?**
No. Peering is non-transitive and does not allow edge-to-edge routing: traffic can't use the other VPC's internet gateway (or NAT) through the peering connection. VPC B has no internet access in this lab.

**Extra points**
- Peering is one-to-one and non-transitive: A-B plus A-C does not give B-C.
- CIDRs must not overlap (10.10.0.0/16 vs 10.20.0.0/16), including secondary CIDRs.
- Private instances have no public IP, so they can't be reached from the internet directly; only the bastion's SSH is exposed, restricted to my /32.
- The longest-prefix route (10.20.0.0/16 -> pcx) wins over 0.0.0.0/0 -> igw in the public route table.
