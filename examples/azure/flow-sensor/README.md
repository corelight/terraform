# Azure VNet Flow Sensor

VNet Flow Logs sensor deployment.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

## What This Deploys

- A Corelight sensor VM (single instance) with management and monitoring NICs
- A user-assigned Managed Identity with `Storage Blob Data Reader` on the flow logs storage account
- The identity is attached to the sensor VM for VNet flow log access

## Variables

See [`terraform.tfvars.example`](./terraform.tfvars.example) for the full list
of inputs.

For deployment guidance, sizing, and architecture details, see the official Corelight documentation.
