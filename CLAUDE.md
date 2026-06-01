# Corelight Terraform Monorepo - Structure Guide

This document provides a comprehensive guide for AI assistants and developers working with the Corelight Terraform monorepo.

## Repository Overview

**Repository**: `github.com/corelight/terraform`
**Current Sensor**: `29.0.5` (see `VERSION`; meta is tag-derived)
**Purpose**: Consolidated Terraform modules for deploying Corelight sensors, enrichment, and Fleet across AWS, GCP, and Azure.

## Core Principles

### 1. Monorepo Structure
All Terraform modules are organized in a single repository with the following top-level directories:
- `modules/` - All Terraform modules (cloud-specific and shared)
- `examples/` - Usage examples organized by cloud provider
- `tests/` - Unit, integration, and E2E tests
- `docs/` - Comprehensive documentation
- `scripts/` - Utility scripts for validation, testing, and release automation

### 2. Versioning Strategy
**Format**: `v<SENSOR_VERSION>-<META>`

- Example: `v29.0.5-3`
  - `29.0.5` = Corelight sensor version
  - `-3` = Third Terraform module release for this sensor version

**Version Rules**:
- The `VERSION` file at the repo root holds the sensor version (e.g. `29.0.5`)
  and is the single source of truth for the sensor. It is bumped by hand.
- The `-<meta>` counter is derived from existing `v<sensor>-*` git tags and
  resets to `1` automatically when the sensor in `VERSION` changes.
- Every merge to `main` triggers `.github/workflows/auto-tag.yml`, which
  computes the next tag, creates it, and publishes a GitHub Release.
- See `scripts/release/README.md` for details and recovery procedures.

### 3. Module Organization

```
modules/
├── _shared/                    # Cloud-agnostic shared modules
│   └── config/
│       ├── sensor/            # Sensor configuration (cloud-init)
│       └── fleet/             # Fleet configuration
├── aws/                       # AWS-specific modules
│   ├── sensor/               # Auto-scaling sensor
│   ├── sensor-single/        # Single instance sensor
│   ├── enrichment/           # Enrichment service
│   └── fleet/                # Fleet manager
├── gcp/                       # GCP-specific modules
│   ├── sensor/               # MIG sensor
│   └── enrichment/           # Enrichment service
└── azure/                     # Azure-specific modules
    ├── sensor/               # Scale set sensor
    └── enrichment/           # Enrichment service
```

### 4. Internal Module References

**Rule**: Internal modules MUST use relative paths, NOT GitHub URLs.

**Examples**:
```terraform
# AWS Sensor referencing shared config
module "sensor_config" {
  source = "../../_shared/config/sensor"
  # ...
}

# GCP Sensor referencing shared config
module "sensor_config" {
  source = "../../_shared/config/sensor"
  # ...
}

# Azure Sensor referencing shared config
module "sensor_config" {
  source = "../../_shared/config/sensor"
  # ...
}
```

### 5. External User References

**Rule**: Users reference modules with double-slash syntax and version tags.

**Examples**:
```terraform
# AWS Sensor
module "sensor" {
  source = "github.com/corelight/terraform//modules/aws/sensor?ref=v29.0.5-1"
  # ...
}

# Submodule (if needed directly)
module "iam_lambda" {
  source = "github.com/corelight/terraform//modules/aws/sensor/submodules/iam-lambda?ref=v29.0.5-1"
  # ...
}
```

### 6. Submodules Pattern

**Rule**: Nested modules are placed in `submodules/` directories.

**Pattern**: `modules/{cloud}/{module}/submodules/{submodule-name}/`

**Example**: `modules/aws/sensor/submodules/iam-lambda/`

## Module Structure Standards

### Required Files for Each Module

1. **Configuration Files**:
   - `*.tf` files (specific to module purpose)
   - `variables.tf` - Input variables
   - `outputs.tf` - Output values
   - `versions.tf` - Terraform and provider version constraints
   - `README.md` - Module documentation

2. **Optional Files** (based on module complexity):
   - `data.tf` - Data sources
   - `locals.tf` - Local values
   - Resource-specific files (e.g., `autoscaling_group.tf`, `load_balancer.tf`)

### AWS Sensor Module Structure

The AWS sensor module is organized by resource type:

```
modules/aws/sensor/
├── autoscaling_group.tf       # ASG configuration
├── data.tf                    # Data sources
├── lambda.tf                  # Lifecycle hook Lambda
├── launch_template.tf         # Launch template for ASG
├── load_balancer.tf           # Gateway load balancer
├── outputs.tf                 # Module outputs
├── security_groups.tf         # Security groups
├── sensor_config.tf           # References ../../_shared/config/sensor
├── variables.tf               # Input variables
├── versions.tf                # Provider constraints
├── README.md                  # Module documentation
└── submodules/
    └── iam-lambda/
        ├── main.tf            # IAM roles and policies
        ├── outputs.tf
        ├── variables.tf
        ├── versions.tf
        └── README.md
```

### Shared Config Sensor Module

The shared sensor configuration module generates cloud-init configuration:

```
modules/_shared/config/sensor/
├── data.tf                    # Cloud-init config generation
├── outputs.tf                 # Config output
├── variables.tf               # Configuration parameters
├── versions.tf                # Provider constraints (cloudinit)
├── README.md                  # Module documentation
└── templates/
    └── cloud-init.yaml.tpl    # Cloud-init template
```

**Key Point**: This module does NOT have a `main.tf` file. Configuration is generated via `data.tf` using the `cloudinit_config` data source.

## Provider Version Constraints

### Root Modules
All root modules must define:
- `required_version` - Terraform version (>= 1.3.2)
- `required_providers` - Provider versions

### AWS Sensor Module
```terraform
terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0"
    }
  }
}
```

### Shared Config Sensor Module
```terraform
terraform {
  required_version = ">= 1.3.2"

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.3.0"
    }
  }
}
```

## Development Workflow

### Task Automation (justfile)

The repository uses `justfile` for common development tasks:

```bash
just fmt        # Format all Terraform files
just lint       # Run tflint recursively on all modules
just validate   # Validate all Terraform modules
just test       # Run tests
```

### Linting

- Uses `tflint` with `--recursive` flag
- Auto-discovers modules by finding `versions.tf` files
- All modules must pass lint checks before committing

### Git Workflow

**Branch Strategy**:
- `main` - Protected branch for releases
- Feature branches: `feature/{description}`

**Current Branch**: `feature/monorepo-structure-and-aws-sensor`

**Commit Guidelines**:
- Descriptive commit messages
- Include footer:
  ```
  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

## Migration Status

### Completed Migrations

1. **terraform-config-sensor** → `modules/_shared/config/sensor/`
   - ✅ All files migrated
   - ✅ Template path updated to `templates/cloud-init.yaml.tpl`
   - ✅ versions.tf added with cloudinit provider

2. **terraform-aws-sensor** → `modules/aws/sensor/`
   - ✅ All files migrated
   - ✅ Internal references updated to use `../../_shared/config/sensor`
   - ✅ Submodules reorganized under `submodules/`
   - ✅ All lint issues resolved

3. **terraform-aws-enrichment** → `modules/aws/enrichment/`
   - ✅ All files migrated
   - ✅ Submodules reorganized under `submodules/iam/`
   - ✅ Example created in `examples/aws/enrichment/`
   - ✅ Tests added

4. **terraform-gcp-sensor** → `modules/gcp/sensor/`
   - ✅ All files migrated
   - ✅ Example created in `examples/gcp/sensor-only/`
   - ✅ Tests added

5. **terraform-gcp-enrichment** → `modules/gcp/enrichment/`
   - ✅ All files migrated
   - ✅ Submodules reorganized under `submodules/org-iam/`
   - ✅ Example created in `examples/gcp/enrichment/`
   - ✅ Comprehensive test suite (12 scenarios, 344 lines)
   - ✅ Documentation and diagrams included
   - ✅ Verified byte-for-byte identical to original module

6. **terraform-azure-sensor** → `modules/azure/sensor/`
   - ✅ All files migrated
   - ✅ Tests added

7. **terraform-azure-enrichment** → `modules/azure/enrichment/`
   - ✅ All files migrated
   - ✅ Example created
   - ✅ Tests added

### Pending Migrations

These modules still need to be migrated from their standalone repositories:

1. **terraform-aws-single-sensor** → `modules/aws/sensor-single/`
2. **terraform-aws-fleet** → `modules/aws/fleet/`
3. **terraform-config-fleet** → `modules/_shared/config/fleet/`

## Important Notes for AI Assistants

### When Working with This Repository

1. **Always verify module paths** - Use relative paths for internal references
2. **Check versions.tf** - Ensure all provider constraints are defined
3. **Run lint checks** - Use `just lint` after making changes
4. **Follow file organization** - AWS sensor uses separate files per resource type (not a single `main.tf`)
5. **No examples in modules** - Module-specific examples should be removed; use top-level `examples/` directory
6. **Version alignment** - Remember version format is `<SENSOR_VERSION>-<METADATA>`

### Common Patterns

**Shared Configuration Module Usage**:
```terraform
# In any sensor module (aws/gcp/azure)
module "sensor_config" {
  source = "../../_shared/config/sensor"

  sensor_license                   = var.license_key
  fleet_community_string           = var.community_string
  fleet_token                      = var.fleet_token
  fleet_url                        = var.fleet_url
  fleet_server_sslname             = var.fleet_server_sslname
  sensor_management_interface_name = "eth1"
  sensor_monitoring_interface_name = "eth0"
  base64_encode_config             = true
  sensor_health_check_http_port    = "41080"
}
```

**Submodule Usage**:
```terraform
# In parent module or example
module "asg_lambda_role" {
  source = "./submodules/iam-lambda"

  # Variables specific to IAM Lambda role
}
```

### Troubleshooting

**Lint Errors**:
- Missing `versions.tf` - Add file with provider constraints
- Unused variables - Remove or mark as used
- Wrong module paths - Verify relative path is correct

**Module Reference Issues**:
- Internal: Use relative paths (`../../_shared/config/sensor`)
- External (users): Use GitHub URL with `//` separator

## Next Steps

To complete the monorepo migration:

1. Create missing root files (LICENSE, .gitignore, .pre-commit-config.yaml)
2. Implement additional GitHub Actions workflows
3. Migrate remaining modules (single-sensor, enrichment, fleet, GCP, Azure)
4. Create working examples in `examples/` directory
5. Write comprehensive documentation in `docs/`
6. Implement testing framework in `tests/`

## Reference Documentation

- Full structure specification: `/Users/jacobfiola/Downloads/MONOREPO_STRUCTURE.md`
- Repository: https://github.com/corelight/terraform
- Current working directory: `/Users/jacobfiola/work/terraform`
