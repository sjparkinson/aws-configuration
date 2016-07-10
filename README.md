# Amazon AWS VPC Definitions

VPCs under managment are `eu-west-1`.

## Configure Terraform Remote State

After cloning this repository run the following to configure remote state.

```
terraform remote config \
    -backend=s3 \
    -backend-config="bucket=mainthread-technology-logs" \
    -backend-config="key=terraform/aws-configuration/terraform.tfstate" \
    -backend-config="region=eu-west-1"
```
