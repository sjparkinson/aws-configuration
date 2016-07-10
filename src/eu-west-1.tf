/**
 * Provider
 */
provider "aws" {
    # Use the standard AWS CLI configuration file or environment variables.
    region = "eu-west-1"
}

/**
 * Outputs
 */
output "public_subnet_ids" {
    value = "${join(aws_subnet.public_subnet.*.id, ",")}"
}

output "private_subnet_ids" {
    value = "${join(aws_subnet.private_subnet.*.id, ",")}"
}

/**
 * VPC
 *
 * @see https://www.terraform.io/docs/providers/aws/r/vpc.html
 * @see https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html#YourVPC
 */
 resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
        Name = "Default eu-west-1 VPC"
    }
}

# A list of availability zones in eu-west-1 we'll assign subnets to.
variable "availability_zones" {
    default = {
        "0" = "eu-west-1a"
        "1" = "eu-west-1b"
        "2" = "eu-west-1c"
    }
}

/**
 * Public Subnets
 *
 * @see https://www.terraform.io/docs/providers/aws/r/subnet.html
 */
resource "aws_subnet" "public_subnet" {
    count = "3"

    vpc_id = "${aws_vpc.default.id}"
    availability_zone = "${lookup(var.availability_zones, count.index)}"
    cidr_block = "10.0.${count.index}.0/24"
    map_public_ip_on_launch = true

    tags {
        Name = "Default ${lookup(var.availability_zones, count.index)} Public Subnet"
    }
}

/**
 * Private Subnets
 *
 * @see https://www.terraform.io/docs/providers/aws/r/subnet.html
 */
resource "aws_subnet" "private_subnet" {
    count = "3"

    vpc_id = "${aws_vpc.default.id}"
    availability_zone = "${lookup(var.availability_zones, count.index)}"
    cidr_block = "10.0.${count.index + 3}.0/24"
    map_public_ip_on_launch = false

    tags {
        Name = "Default ${lookup(var.availability_zones, count.index)} Private Subnet"
    }
}

/**
 * Internet Gateways
 *
 * @see https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
 */
resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "Default eu-west-1 Internet Gateway"
    }
}

/**
 * DHCP Options
 *
 * @see https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options.html
 * @see https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_DHCP_Options.html
 */
resource "aws_vpc_dhcp_options" "default" {
    domain_name = "eu-west-1.compute.internal"
    domain_name_servers = ["AmazonProvidedDNS"]

    tags {
        Name = "Default eu-west-1 DHCP Options"
    }
}

# @see https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options_association.html
resource "aws_vpc_dhcp_options_association" "default" {
    vpc_id = "${aws_vpc.default.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.default.id}"
}

/**
 * ACL
 *
 * Using `aws_default_network_acl` allows us to manage the default
 * ACL that AWS creates with a new VPC.
 *
 * @see https://www.terraform.io/docs/providers/aws/r/default_network_acl.html
 */
resource "aws_default_network_acl" "default" {
    default_network_acl_id = "${aws_vpc.default.default_network_acl_id}"

    # We also need to explicitly add subnets so that Terraform doesn't
    # keep trying to remove them.
    # @see https://www.terraform.io/docs/providers/aws/r/default_network_acl.html
    subnet_ids = ["${concat(aws_subnet.public_subnet.*.id, aws_subnet.private_subnet.*.id)}"]

    ingress {
        protocol   = -1
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }

    egress {
        protocol   = -1
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }

    tags {
        Name = "Default eu-west-1 Network ACL"
    }
}

/**
 * Routes
 */
resource "aws_route" "public_internet_gateway_route" {
    # We need to map the Internet Gateway to our VPC with a route to allow instances
    # in public subnets access to the internet.
    route_table_id = "${aws_vpc.default.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
}

resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.default.id}"

    # By default AWS creates the `local` route mapping we need.

    tags {
        Name = "Default eu-west-1 Private Route Table"
    }
}

/**
 * Route Accociations
 */
resource "aws_route_table_association" "public_subnets" {
    count = "3"

    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    route_table_id = "${aws_vpc.default.main_route_table_id}"
}

resource "aws_route_table_association" "private_subnets" {
    count = "3"

    subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

/**
 * Security Group
 *
 * Provides a basic set of rules for instances.
 *
 * @see https://www.terraform.io/docs/providers/aws/r/security_group.html
 */
resource "aws_security_group" "default" {
    name = "Default eu-west-1 Security Group"
    vpc_id = "${aws_vpc.default.id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "Default eu-west-1 Security Group"
        Description = "Allow SSH inbound, allow all outbound."
    }
}

/**
 * EC2 Key Pairs
 *
 * @see https://www.terraform.io/docs/providers/aws/r/key_pair.html
 */
resource "aws_key_pair" "default" {
    key_name = "Default eu-west-1 Key Pair"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC268iroYGS1LlSKsvT+ZhlYVMkh8DDRpWiSMUHoHTMREfmq/H1m7rZC1AMOjPQn3lg7fWsfGOpe2QfK6+1/WAg5z8B+lXOPB0dZZ39mME46P8FpQCRbSBXcI6qIBkx9kIJP+psbILrYIlBLBT+JaPcXm/0RDrwhlmYpMPliu4Cyxf5Rpv/dhvcLPptnI0//xhvXhyXQOix0NdGX9CVHjrk/KOE7+NVmyf5dKBsEjbgR8rLH2v6iH99Ua9gv9QC9sBLPBHzIDlW97dVG1BepLrAS7W6nQKSMK4pEJiKV9AHGpdPPpShd19KpBoKBqyCjHYstZXlyTfffqUk3M6F6DQ/ eu-west-1"
}
