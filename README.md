- [Infrastructure](#infrastructure)
  - [Environment: tfstate](#environment-tfstate)
  - [Environment: production](#environment-production)
- [Development Guidelines](#development-guidelines)
  - [Workspace (Devcontainer)](#workspace-devcontainer)
  - [Debugging](#debugging)
  - [Testing](#testing)
    - [Linting](#linting)
    - [Unit Tests](#unit-tests)
  - [Continuous Integration (CI)](#continuous-integration-ci)

# Infrastructure

## Environment: tfstate

This environment sets up the S3 bucket for storing Terraform state files. Just need to run `terraform init` and `terraform apply` here once to create the bucket. After that, other repositories and environments can use this bucket for remote state storage.

## Environment: production

# Development Guidelines

## Workspace (Devcontainer)

## Debugging

## Testing

### Linting

### Unit Tests

## Continuous Integration (CI)
