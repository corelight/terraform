# AWS Modules

Terraform modules for deploying Corelight infrastructure on Amazon Web Services.

| Module | Purpose |
|---|---|
| [`sensor`](./sensor/) | Auto-scaling sensor deployment with Gateway Load Balancer (GWLB) |
| [`sensor-single`](./sensor-single/) | Single-instance sensor for small or test deployments |
| [`enrichment`](./enrichment/) | Enrichment service (Lambda + EventBridge) |
| [`fleet`](./fleet/) | Fleet manager deployment |

For deployment guidance and architecture details, see the official Corelight documentation.
