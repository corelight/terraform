# Azure Scripts

Utility scripts for managing Corelight sensor images in Azure.

## copy-azure-image.sh

Copies a Corelight sensor VHD blob from a source Azure storage account (via SAS URL) to a destination storage account, then creates a managed image from it.

### Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (`az`) installed and authenticated
- [AzCopy](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10) installed
- An active Azure subscription

### Usage

```bash
# Minimal: auto-creates resource group, storage account, and container
./copy-azure-image.sh --source-sas "https://sourceaccount.blob.core.windows.net/container/corelight-v29.0.5.vhd?sp=r&st=..."

# Use an existing resource group and storage account
./copy-azure-image.sh \
  --source-sas "https://sourceaccount.blob.core.windows.net/container/corelight-v29.0.5.vhd?sp=r&st=..." \
  --dest-resource-group "my-rg" \
  --dest-account-name "mystorageaccount" \
  --dest-container-name "vhds"

# Specify a different Azure region
./copy-azure-image.sh \
  --source-sas "https://sourceaccount.blob.core.windows.net/container/corelight-v29.0.5.vhd?sp=r&st=..." \
  --dest-location "West US 2"
```

You can also curl and run directly:

```bash
curl -s https://raw.githubusercontent.com/corelight/terraform/refs/heads/main/scripts/azure/copy-azure-image.sh \
  | bash -s -- --source-sas "https://sourceaccount.blob.core.windows.net/container/corelight-v29.0.5.vhd?sp=r&st=..."
```

### Options

| Flag | Required | Description |
|------|----------|-------------|
| `--source-sas` | Yes | Source blob SAS URL provided by Corelight |
| `--dest-account-name` | No | Destination storage account (auto-created if omitted) |
| `--dest-container-name` | No | Destination container (auto-created if omitted) |
| `--dest-resource-group` | No* | Destination resource group (*required when using existing resources) |
| `--dest-location` | No | Azure region for auto-created resources (default: "East US") |

### Hyper-V Generation

The script automatically detects the sensor version from the SAS URL and selects the appropriate Hyper-V generation:

- Sensor versions **< 28.4.0** use Hyper-V Generation **V1**
- Sensor versions **>= 28.4.0** use Hyper-V Generation **V2**

If the version cannot be detected, it defaults to V2.
