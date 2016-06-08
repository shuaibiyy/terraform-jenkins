# Terraformed Jenkins

Deploy Jenkins 2.0 in a [docker container](https://hub.docker.com/r/library/jenkins/tags/) on an AWS EC2 instance using [Terraform](https://www.terraform.io/).

The terraform script stores the terraform state remotely in an S3 bucket. The Makefile by default sets up a copy of the remote state if it doesn’t exist and then runs either `terraform plan` or `terraform apply` depending on the target.

## Usage

Before you run the Makefile, you should set the following environment variables to authenticate with AWS:
```
$ export AWS_ACCESS_KEY_ID= <your key> # to store and retrieve the remote state in s3.
$ export AWS_SECRET_ACCESS_KEY= <your secret>
$ export AWS_DEFAULT_REGION= <your bucket region e.g. us-west-2>
$ export TF_VAR_access_key=$AWS_ACCESS_KEY # exposed as access_key in terraform scripts
$ export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY # exposed as secret_key in terraform scripts
```

You need to change the default values of `s3_bucket` and `key_name` terraform variables defined in `variables.tf` or set them via environment variables:
```
$ export TF_VAR_s3_bucket=<your s3 bucket>
$ export TF_VAR_key_name=<your keypair name>
```
You also need to change the value of `STATEBUCKET` in the Makefile to match that of the `s3_bucket` terraform variable.

### Run 'terraform plan'

    make

### Run 'terraform apply'

    make apply


### Run 'terraform destroy'

    make destroy

Upon completion, terraform will output the DNS name of Jenkins, e.g.:
```
jenkins_public_dns = [ ec2-54-235-229-108.compute-1.amazonaws.com ]
```
You can then reach Jenkins via your browser at `http://ec2-54-235-229-108.compute-1.amazonaws.com`.

## Configuring Backup

After the Jenkins EC2 instance is started, a cronjob is configured to back up Jenkins data to an S3 bucket set via the `s3_bucket` variable (see variables.tf). To accomplish this, a script needs to be copied onto the EC2 instance, therefore, Terraform requires SSH access to the instance.

To grant SSH access to Terraform, place the instance's PEM file in this project's directory. Note that the key file should have the same name as the EC2 keypair, or you can update the `key_file` variable in the connection section of the Terraform EC2 resource (see main.tf).

## Monitoring

The AMI on which Jenkins is run has [Weave Scope](https://www.weave.works/products/weave-scope/) pre-installed. Scope is a Docker monitoring, visualisation and management tool from Weaveworks.

The Scope UI can be reached at the URL of the Jenkins instance on port 4040, e.g. `http://ec2-54-235-229-108.compute-1.amazonaws.com:4040`.

## Credits

* The Makefile idea (and the Makefile itself) is taken from this [blog post](http://karlcode.owtelse.com/blog/2015/09/01/working-with-terraform-remote-statefile/).
