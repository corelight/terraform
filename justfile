set shell := ["bash", "-cu"]

default:
    @just --list

# Run tflint on all modules and verify generated docs are up to date
lint:
    tflint --init
    tflint --recursive
    just docs-check

# Regenerate Inputs/Outputs tables in module READMEs via terraform-docs
docs:
    terraform-docs --recursive --recursive-path modules --recursive-include-main=false .

# Fail if module READMEs are out of date with variables.tf / outputs.tf
docs-check:
    terraform-docs --recursive --recursive-path modules --recursive-include-main=false --output-check .

# Check Terraform formatting
fmt-check:
    terraform fmt -check -recursive .

# Format Terraform files
fmt:
    terraform fmt -recursive .

# Validate all Terraform modules
validate:
    #!/usr/bin/env bash
    set -euo pipefail
    for module in $(find . -type f -name "versions.tf" -not -path "*/.terraform/*" -exec dirname {} \; | sort -u); do
      echo "Validating $module..."
      (cd "$module" && terraform init -backend=false && terraform validate && rm -rf .terraform .terraform.lock.hcl)
    done

# Run all tests
test: test-unit test-aws test-release

# Run Terraform unit tests
test-unit:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Running unit tests..."
    for test_dir in $(find examples modules -name "*.tftest.hcl" -exec dirname {} \; | sort -u); do
      parent_dir=$(dirname "$test_dir")
      echo "Testing: $parent_dir"
      (cd "$parent_dir" && terraform init -backend=false && terraform init -test-directory=tests -backend=false && terraform test) || exit 1
    done

# Run AWS Lambda Python tests
test-aws:
    #!/usr/bin/env bash
    set -euo pipefail
    cd modules/aws/sensor/scripts
    if [ ! -d ".venv" ]; then
      python3 -m venv .venv
    fi
    .venv/bin/pip install -q -r requirements.txt -r tests/test-requirements.txt
    .venv/bin/pytest tests/ -v

# Run release-script tests
test-release:
    ./scripts/release/test_compute_next_tag.sh

# Run Trivy security scan
trivy-scan:
    trivy fs --config .github/trivy/trivy.yml .

# Clean Terraform files
clean:
    find . -type d -name ".terraform" -exec rm -rf {} +
    find . -type f -name "*.tfstate*" -delete
    find . -type f -name ".terraform.lock.hcl" -delete
    find . -type d -name ".venv" -exec rm -rf {} +
    find . -type d -name "__pycache__" -exec rm -rf {} +
