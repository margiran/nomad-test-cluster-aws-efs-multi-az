# Provision a Nomad cluster on AWS Using Terraform
# A sample of using CSI plugin with AWS EFS in multi avalibality zones
## include the Nomad job files for plugins 

## Pre-requisites

* You must have [Terraform](https://www.terraform.io/downloads) installed on your computer. 
* You must have an [Amazon Web Services (AWS) account](http://aws.amazon.com/).


## Quick start

### Set the AWS environment variables:

Configure your [AWS access 
keys](http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) as 
environment variables:
```
export AWS_ACCESS_KEY_ID=(your access key id)
export AWS_SECRET_ACCESS_KEY=(your secret access key)
```

### Clone the repository:

```
git clone git@github.com:margiran/nomad-test-cluster-aws-efs-multi-az.git
cd nomad-test-cluster-aws-efs-multi-az
```
### Build infrastructure using Terraform:

```
terraform init
terraform apply
```
### Access the cluster

Use following commands to capture the private key in a pem file:

```
terraform output private_key_pem | grep -v EOT > ~/.ssh/terraform.pem
chmod 0600 ~/.ssh/terraform.pem
```

for simplicity we generate the ssh command in an output, so try following command and use the value of output to ssh to the Nomad server:

```
terraform output ssh_nomad_server_public_ip
```

### Nomad sample job

- get NOMAD_ADDR for server 

```
terraform output nomad_addr_nomad_server_public_ip
```

- set NOMAD_ADDR variable ( get one of the server address )

```
export NOMAD_ADDR=http://10.10.10.10:4646
```

- to check nomad jobs ( plugin jobs )

```
nomad job status
```

- to check the csi plugin 

```
nomad plugin status aws-efs0
```

- to check the volume status

```
nomad volume status volume-test
```

- to check the mounted volumes 

```
$ nomad job status test-csi

ID            = test-csi
Name          = test-csi
.
.
.

Allocations
ID        Node ID   Task Group  Version  Desired  Status   Created     Modified
c8ce16be  5dc200c1  test-group  0        run      running  17m12s ago  16m55s ago
8e88b8e9  a731dd38  test-group  0        run      running  17m42s ago  17m21s ago

$ nomad alloc exec -i -t -task volumetest c8ce16be df
Filesystem            1K-blocks    Used        Available Use% Mounted on
 .
127.0.0.1:/    9007199254739968       0 9007199254739968   0% /data
 .
 .
```

### Clean up when you're done:

```
terraform destroy
```

### Sample output

```
terraform init
```

We use our local machine to provision infrastructure we have as code, Terraform needs some binaries in order to interact with the provider API. by execute `init` command terraform will download needed binaries. 
this is the output of this command:

    Initializing the backend...

    Initializing provider plugins...
    - Reusing previous version of hashicorp/aws from the dependency lock file
    - Reusing previous version of hashicorp/tls from the dependency lock file
    - Using previously-installed hashicorp/aws vN.NN.N
    - Using previously-installed hashicorp/tls vN.NN.N

    Terraform has been successfully initialized!

```
terraform apply
```

when you run the `apply` command terraform will show the plan (a list of resources need to create/change to achieve yor desire state) and ask for your approval, you need to type 'yes':
```
    Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.

      Enter a value:  
```

At the end terraform will show a message that indicate your infrastructure is ready:
```
  Apply complete! Resources: N added, 0 changed, 0 destroyed.
  .
  .
  .
  END
```
