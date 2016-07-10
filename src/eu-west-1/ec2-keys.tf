/**
 * @see https://www.terraform.io/docs/providers/aws/r/key_pair.html
 */
resource "aws_key_pair" "default" {
    key_name = "Default eu-west-1 Key Pair"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC268iroYGS1LlSKsvT+ZhlYVMkh8DDRpWiSMUHoHTMREfmq/H1m7rZC1AMOjPQn3lg7fWsfGOpe2QfK6+1/WAg5z8B+lXOPB0dZZ39mME46P8FpQCRbSBXcI6qIBkx9kIJP+psbILrYIlBLBT+JaPcXm/0RDrwhlmYpMPliu4Cyxf5Rpv/dhvcLPptnI0//xhvXhyXQOix0NdGX9CVHjrk/KOE7+NVmyf5dKBsEjbgR8rLH2v6iH99Ua9gv9QC9sBLPBHzIDlW97dVG1BepLrAS7W6nQKSMK4pEJiKV9AHGpdPPpShd19KpBoKBqyCjHYstZXlyTfffqUk3M6F6DQ/ eu-west-1"
}
