# AWS Sensor Single

Single-instance sensor with optional VPC Flow Logs ingestion.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

## Variables

See [`terraform.tfvars.example`](./terraform.tfvars.example) for the full list
of inputs.

For deployment guidance, sizing, and architecture details, see the official Corelight documentation.
