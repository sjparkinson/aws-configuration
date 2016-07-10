# Use the standard AWS CLI configuration file or environment variables.
provider "aws" {
    region = "eu-west-1"
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

/**
 * Public Subnets
 *
 * @see https://www.terraform.io/docs/providers/aws/r/subnet.html
 */
resource "aws_subnet" "public_subnet_a" {
    vpc_id = "${aws_vpc.default.id}"
    availability_zone = "eu-west-1a"
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true

    tags {
        Name = "Default eu-west-1a Public Subnet"
    }
}

resource "aws_subnet" "public_subnet_b" {
    vpc_id = "${aws_vpc.default.id}"
    availability_zone = "eu-west-1b"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true

    tags {
        Name = "Default eu-west-1b Public Subnet"
    }
}

resource "aws_subnet" "public_subnet_c" {
    vpc_id = "${aws_vpc.default.id}"
    availability_zone = "eu-west-1c"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true

    tags {
        Name = "Default eu-west-1c Public Subnet"
    }
}

/**
 * Private Subnets
 *
 * @see https://www.terraform.io/docs/providers/aws/r/subnet.html
 */
resource "aws_subnet" "private_subnet_a" {
    vpc_id = "${aws_vpc.default.id}"
    availability_zone = "eu-west-1a"
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = false

    tags {
        Name = "Default eu-west-1a Private Subnet"
    }
}

resource "aws_subnet" "private_subnet_b" {
    vpc_id = "${aws_vpc.default.id}"
    availability_zone = "eu-west-1a"
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = false

    tags {
        Name = "Default eu-west-1b Private Subnet"
    }
}

resource "aws_subnet" "private_subnet_c" {
    vpc_id = "${aws_vpc.default.id}"
    availability_zone = "eu-west-1c"
    cidr_block = "10.0.5.0/24"
    map_public_ip_on_launch = false

    tags {
        Name = "Default eu-west-1c Private Subnet"
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
