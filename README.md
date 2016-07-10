# Amazon AWS VPC Definitions

VPCs under managment are `eu-west-1`.

## Configure Terraform Remote State

```
terraform remote config \
    -backend=s3 \
    -backend-config="bucket=mainthread-technology-logs" \
    -backend-config="key=terraform/eu-west-1/terraform.tfstate" \
    -backend-config="region=eu-west-1"
```
