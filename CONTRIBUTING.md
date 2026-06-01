# Contributing to Corelight Terraform Modules

Thank you for your interest in contributing to the Corelight Terraform modules!

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development Workflow

### Format Your Code

```bash
terraform fmt -recursive .
```

### Validate

```bash
just validate
just lint
```

### Test

```bash
cd tests/unit
go test -v ./...
```

## Module Standards

- Use `lowercase-with-hyphens` for module names
- Use `snake_case` for files and variables
- Include README.md, variables.tf, outputs.tf, versions.tf
- Use relative paths for internal module references

## Documentation

- Update module README.md
- Update examples if behavior changes
- Update CHANGELOG.md

## Submitting Changes

1. Commit with clear messages
2. Push to your fork
3. Create a pull request
4. Fill out the PR template
5. Address review feedback

See the full documentation in [docs/development/](./docs/development/).
