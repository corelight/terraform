---
generated_by: claude-opus-5[1m]
generated_at: 2026-08-13
---

# Corelight Terraform Monorepo

`github.com/corelight/terraform`. A module *library*, not a deployment root: it publishes
reusable Terraform modules for deploying Corelight sensors, Fleet, and cloud enrichment across
AWS, Azure, and GCP. The primary consumer is `enrichment-deploy` (a separate GitLab repo), which
pins modules via `source = "github.com/corelight/terraform//modules/<cloud>/<module>?ref=..."`.

This is a **public** repository. Never add internal-only detail: no GitLab project IDs, no
internal registry hostnames, no cloud account/subscription/project identifiers, no tokens, no
internal URLs.

## Module inventory

- `_shared/config/sensor` - cloud-agnostic sensor cloud-init generator (no `main.tf`; config is
  built in `data.tf` via the `cloudinit_config` data source). Used by every cloud's sensor module.
- `_shared/config/fleet` - cloud-agnostic Fleet Manager cloud-init generator.
- `aws/sensor` - auto-scaling sensor via ASG + Gateway Load Balancer; ships a
  `submodules/iam-lambda` submodule for the ASG lifecycle-hook Lambda's IAM role.
- `aws/sensor-single` - single EC2 instance sensor (no ASG/GWLB); submodules for `instance`,
  `network_interface`, and `vpc_flow_assume_role`.
- `aws/fleet` - Fleet Manager on ALB + EC2 + Route53.
- `aws/enrichment` - Lambda + EventBridge enrichment; submodules under `submodules/iam/*` and
  `submodules/secondary-event-rule`.
- `azure/sensor` - auto-scaling sensor via VM Scale Set with internal LB and NAT gateway.
- `azure/sensor-single` - single sensor VM; submodule `vnet_flow_storage_access`.
- `azure/enrichment` - Container App + Service Bus + Storage; submodules `iam`, `service_bus`,
  `storage`.
- `gcp/sensor` - auto-scaling sensor via Managed Instance Group with internal LB and Packet
  Mirroring.
- `gcp/enrichment` - Cloud Run + Pub/Sub + Cloud Scheduler; submodule `org-iam`.

`sensor` modules are the fleet-managed, auto-scaling deployment topology per cloud; `sensor-single`
is a simpler, single-instance deployment without scaling infrastructure. Both consume
`_shared/config/sensor` for cloud-init.

## Consumer hazard: `?ref=main`

`auto-tag.yml` (below) publishes a new tag and GitHub Release on every merge to `main`. If a
consumer pins `?ref=main` instead of a release tag, it tracks unreleased HEAD rather than a
published release. State this as fact when it comes up; it is documented on the consumer side too.

## Versioning

Format: `v<SENSOR_VERSION>-<META>` (e.g. `v29.0.5-5`).

- `VERSION` (repo root, one line, e.g. `29.0.5`) is the Corelight sensor version. Bumped by hand
  when a new sensor ships.
- `<META>` is derived from existing `v<sensor>-*` git tags: `(highest existing meta) + 1`, or `1`
  if none exist for that sensor. It resets to `1` automatically when `VERSION` changes.
- `.github/workflows/auto-tag.yml` runs on every push to `main`: computes the next tag via
  `scripts/release/compute-next-tag.sh`, pushes the tag, and runs `gh release create <tag>
  --generate-notes`. A `concurrency` group serializes runs.
- Details and force-push recovery: `scripts/release/README.md`.
- Test the tag logic: `just test-release` (wraps `scripts/release/test_compute_next_tag.sh`).

## Module source conventions (load-bearing)

- **Internal references MUST use relative paths**, never GitHub URLs, e.g.
  `source = "../../_shared/config/sensor"`.
- **External consumers** use `source = "github.com/corelight/terraform//modules/<cloud>/<module>?ref=<tag>"`.
- Nested modules live under `modules/<cloud>/<module>/submodules/<name>/` (e.g.
  `modules/aws/sensor/submodules/iam-lambda`).
- Every module file is organized resource-type-per-file (`autoscaling_group.tf`,
  `load_balancer.tf`, `security_groups.tf`, ...), not one giant `main.tf`. The
  `_shared/config/sensor` module deliberately has no `main.tf`; its logic lives in `data.tf`.
- Required per-module files: `README.md`, `variables.tf`, `outputs.tf`, `versions.tf`.
- Provider version constraints live in each module's own `versions.tf`, not centrally.
- Naming: module directories `lowercase-with-hyphens`; files and variables `snake_case`.
- Tests live per-module/per-example at `modules/*/*/tests/*.tftest.hcl` and
  `examples/*/*/tests/*.tftest.hcl`, not in a root `tests/` (none exists). Per-module `docs/`
  directories exist for `azure/enrichment`, `azure/sensor`, `gcp/enrichment`; there is no root
  `docs/`.

## Docs generation gotcha (high value)

Module README Inputs/Outputs tables are generated, not hand-written, via terraform-docs with
`--output-check` mode injecting between `<!-- BEGIN_TF_DOCS -->` / `<!-- END_TF_DOCS -->` markers
(`.terraform-docs.yml`). **If you edit any module's `variables.tf` or `outputs.tf`, run `just
docs` before committing**, or CI's `just lint` (which calls `just docs-check`) will fail.

```
just docs        # regenerate Inputs/Outputs tables
just docs-check  # fail if README tables are stale (what CI runs)
```

## justfile recipes (verbatim from `justfile`)

`fmt`, `fmt-check`, `validate`, `lint` (`tflint --init && tflint --recursive && just docs-check`),
`docs`, `docs-check`, `test` (`test-unit test-aws test-release`), `test-unit`, `test-aws` (AWS
Lambda Python tests via pytest), `test-release`, `trivy-scan`, `clean`. Run `just --list` for the
current set.

## CI workflows (`.github/workflows/`)

- `terraform-lint.yml`: on push/PR to `main`, runs `just fmt-check`, then `just lint` (tflint +
  docs-check) and `just test-release`. Pins Terraform `1.14.0`, terraform-docs `v0.24.0`, just
  `1.51.0`.
- `terraform-test.yml`: on push/PR/dispatch, runs `just test-unit` (Terraform `~> 1.10`), `just
  test-aws` (Python 3.12), and a separate Terraform Validate job.
- `scan-trivy.yml`: on PR to `main`, nightly cron, and dispatch; runs
  `corelight/shared-actions/trivy-terraform-scan@main` against `.github/trivy/trivy.yml`,
  opening issues on findings.
- `auto-tag.yml`: see Versioning above.

## Environment notes for this session

Local Terraform is `1.12.2` and local terraform-docs is `v0.17.0`; CI pins Terraform `1.14.0` and
terraform-docs `v0.24.0`. `v0.17.0` does not support the `--recursive-include-main` flag used in
`just docs`/`just docs-check`, so those recipes cannot be validated locally without upgrading
terraform-docs; treat failures there as version skew, not a repo defect. `tflint` is commonly not
installed locally, so `just lint` fails at its first step for that reason alone.

Two modules currently fail `terraform validate` against recent provider releases (unrelated to any
docs change): `modules/azure/enrichment` (`service_bus_queue_endpoint_id` argument no longer valid
on `azurerm_eventgrid_system_topic_event_subscription` under azurerm provider `5.0.1`, though the
module's `versions.tf` only requires `>= 4.0`) and `modules/azure/sensor`
(`enable_accelerated_networking` unsupported on `azurerm_linux_virtual_machine_scale_set` under the
same provider version). This also fails the corresponding `azure/enrichment` unit test. If you hit
either error, it is a known provider-compatibility gap, not something introduced by an unrelated
change; consider pinning `azurerm` tighter in those modules' `versions.tf` if you're the one fixing
it.

## Never do

Never run `terraform apply` or `terraform destroy` in this repo.
