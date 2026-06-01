# Corelight Terraform Modules

A multi-cloud Terraform module repository for deploying and managing Corelight network sensors across AWS, Azure, and Google Cloud Platform.

## Overview

This monorepo contains reusable Terraform modules for deploying Corelight sensors and related infrastructure. Modules are organized by cloud provider for easy navigation and consumption.

## Repository Structure

```
terraform/
├── modules/               # All Terraform modules
│   ├── _shared/          # Cloud-agnostic shared modules
│   ├── aws/              # AWS-specific modules
│   ├── gcp/              # GCP-specific modules
│   └── azure/            # Azure-specific modules
├── examples/             # Usage examples by cloud provider
├── tests/                # Unit, integration, and E2E tests
└── scripts/              # Utility scripts
```

## Available Modules

### Shared Modules

- **[modules/_shared/config/sensor](./modules/_shared/config/sensor/)** - Cloud-agnostic sensor configuration generator (cloud-init)
- **[modules/_shared/config/fleet](./modules/_shared/config/fleet/)** - Fleet manager configuration

### AWS Modules

- **[modules/aws/sensor](./modules/aws/sensor/)** - Auto-scaling sensor deployment with Gateway Load Balancer
- **[modules/aws/sensor-single](./modules/aws/sensor-single/)** - Single instance sensor deployment
- **[modules/aws/enrichment](./modules/aws/enrichment/)** - AWS enrichment infrastructure
- **[modules/aws/fleet](./modules/aws/fleet/)** - Fleet manager deployment

### GCP Modules

- **[modules/gcp/sensor](./modules/gcp/sensor/)** - Managed Instance Group sensor deployment
- **[modules/gcp/enrichment](./modules/gcp/enrichment/)** - GCP enrichment infrastructure

### Azure Modules

- **[modules/azure/sensor](./modules/azure/sensor/)** - Virtual Machine Scale Set sensor deployment
- **[modules/azure/enrichment](./modules/azure/enrichment/)** - Azure enrichment infrastructure

## Quick Start

### Using Modules

Reference modules using GitHub source with version tags:

```hcl
module "sensor" {
  source = "github.com/corelight/terraform//modules/aws/sensor?ref=v29.0.5-1"

  vpc_id                   = "vpc-xxxxx"
  corelight_sensor_ami_id  = "ami-xxxxx"
  # ... other variables
}
```

### Examples

Complete, runnable examples are available for each cloud provider:

- **AWS**: [examples/aws/](./examples/aws/) - Complete deployment, sensor-only, enrichment, Fleet
- **GCP**: [examples/gcp/](./examples/gcp/) - Complete deployment, sensor-only, enrichment
- **Azure**: [examples/azure/](./examples/azure/) - Complete deployment, sensor-only, enrichment

## Versioning Strategy

This repository uses **sensor-aligned versioning** where the version tracks the Corelight sensor version compatibility plus a metadata version for Terraform-specific changes.

### Version Format

```
<SENSOR_VERSION>-<TERRAFORM_METADATA>
```

**Examples**:
- `29.0.5-1` - First Terraform release for Corelight sensor 29.0.5
- `29.0.5-2` - Second Terraform release (Terraform changes only, same sensor)
- `29.1.0-1` - First Terraform release for Corelight sensor 29.1.0

### Version Components

| Component | Description | Example |
|-----------|-------------|---------|
| **SENSOR_VERSION** | Corelight sensor version compatibility | `29.0.5` |
| **TERRAFORM_METADATA** | Terraform-specific release number | `1`, `2`, `3`, etc. |

### Git Tags

- Format: `v<VERSION>` (e.g., `v29.0.5-1`)
- All modules share the same version
- Pin to specific versions in production

## Migration from v1.x

If you're migrating from the standalone v1.x repositories, update your module source references:

**Before (v1.x standalone repos)**:
```hcl
module "config" {
  source = "github.com/corelight/terraform-config-sensor?ref=v1.0.0"
}

module "sensor" {
  source = "github.com/corelight/terraform-aws-sensor?ref=v1.0.0"
}
```

**After (v29.0.5-1 monorepo)**:
```hcl
module "config" {
  source = "github.com/corelight/terraform//modules/_shared/config/sensor?ref=v29.0.5-1"
}

module "sensor" {
  source = "github.com/corelight/terraform//modules/aws/sensor?ref=v29.0.5-1"
}
```

Update each module source as shown above; see the per-module READMEs under [modules/](./modules/) for module-specific inputs and outputs.

## Documentation

Documentation lives alongside the code:

- **Modules** - Each module has its own README under [modules/](./modules/) documenting its inputs, outputs, and usage.
- **Examples** - Runnable, documented examples under [examples/](./examples/).
- **Contributing** - See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Development

### Adding New Modules

1. Choose the correct directory:
   - Cloud-specific modules: `modules/aws/`, `modules/gcp/`, or `modules/azure/`
   - Cloud-agnostic modules: `modules/_shared/`

2. Follow naming conventions:
   - Module names: `lowercase-with-hyphens`
   - Files: `snake_case.tf`
   - Variables/outputs: `snake_case`

3. Required files:
   - `README.md` - Module documentation
   - `variables.tf` - Input variables
   - `outputs.tf` - Output values
   - `versions.tf` - Terraform and provider version constraints

4. Internal dependencies:
   - Use relative paths: `source = "../../_shared/config/sensor"`
   - Do NOT use GitHub source for internal references

### Testing

All modules must pass validation before merging:

```bash
# Format all files
just fmt

# Check formatting
just fmt-check

# Validate all modules
just validate

# Run linting
just lint

# Run tests
just test-aws
```

Run `just --list` to see all available tasks.

### CI/CD

GitHub Actions automatically:
- Validates Terraform formatting
- Runs `terraform validate` on all modules
- Executes cloud-specific tests
- Performs security scanning with Trivy
- Creates releases when VERSION file changes

## Contributing

We welcome contributions! Please see:
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Contribution guidelines

## Requirements

- **Terraform**: >= 1.3.2
- **Provider versions**: See individual module `versions.tf` files

## Support

- **Issues**: [GitHub Issues](https://github.com/corelight/terraform/issues)
- **Documentation**: Module-specific READMEs under [modules/](./modules/) and examples under [examples/](./examples/)

## License

Copyright (c) 2024 Corelight, Inc.

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
