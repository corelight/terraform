# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Version format: `<SENSOR_VERSION>-<TERRAFORM_METADATA>`
- The first part matches the Corelight sensor version this Terraform code is compatible with
- The second part is a metadata version for Terraform-specific changes

## [Unreleased]

### Added

- **gcp/enrichment** module - GCP enrichment service deployment with Cloud Run, Pub/Sub, and Cloud Scheduler (migrated from terraform-gcp-enrichment)
  - Automated cloud resource metadata collection
  - Cloud Asset Inventory integration
  - Event-driven and scheduled collection modes
  - GCS bucket for enrichment data storage
  - Organization-level IAM role for multi-project access

### Changed

- **examples/aws/flow-sensor** - Rewritten as a single-sensor example with an inline IAM role/instance profile, replacing the previous module-based deployment

### Removed

- **aws/flow-sensor** module - Superseded by the simpler `examples/aws/flow-sensor` example built on `aws/sensor-single`
- **aws/cloud-vpc-flow-infra** module - Removed alongside `aws/flow-sensor`; the SQS/ElastiCache infrastructure it provided is no longer required for the supported deployment topology
- **aws/flow-connector-infra** module - Orphaned duplicate of `aws/cloud-vpc-flow-infra` left over from the rename in PR #17

### Migrated

- terraform-gcp-enrichment → gcp/enrichment

## [28.4.0-1] - 2025-12-01

### Added

- Initial monorepo structure with cloud provider organization
- **shared/config-sensor** module - Cloud-agnostic sensor configuration generator (migrated from terraform-config-sensor v1.2.0)
- **aws/sensor** module - AWS sensor deployment with ASG, GWLB, and Lambda-based ENI management (migrated from terraform-aws-sensor v1.x)
- **aws/enrichment** module - AWS enrichment service with Lambda and EventBridge
- **gcp/sensor** module - GCP sensor deployment with Managed Instance Group
- **azure/sensor** module - Azure sensor deployment with Scale Sets
- **azure/enrichment** module - Azure enrichment service with Container Apps
- Sensor-aligned versioning strategy with unified VERSION file
- Comprehensive GitHub Actions CI/CD workflows
- Module development guidelines in root README.md
- Migration guide for v1.x users

### Changed

- **BREAKING**: Module source paths changed from standalone repos to monorepo paths
  - `github.com/corelight/terraform-config-sensor` → `github.com/corelight/terraform//shared/config-sensor`
  - `github.com/corelight/terraform-aws-sensor` → `github.com/corelight/terraform//aws/sensor`
  - `github.com/corelight/terraform-gcp-enrichment` → `github.com/corelight/terraform//gcp/enrichment`
- Internal dependencies now use relative paths within monorepo
- Renamed `modules/iam/lambda/` to `modules/iam-lambda/` in aws/sensor

### Migrated

- terraform-config-sensor (v1.2.0) → shared/config-sensor
- terraform-aws-sensor (v1.x) → aws/sensor
- terraform-aws-enrichment → aws/enrichment
- terraform-gcp-sensor → gcp/sensor
- terraform-azure-sensor → azure/sensor
- terraform-azure-enrichment → azure/enrichment

### Compatible With

- Corelight Sensor: 28.4.0

[28.4.0-1]: https://github.com/corelight/terraform/releases/tag/v28.4.0-1
