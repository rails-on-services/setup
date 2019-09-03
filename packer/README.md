## Installation

This repository provides packer templates to build vagrant boxes

Clone the prepd-cli repository:

```bash
git clone git@github.com:rjayroach/packer.git
cd packer
./setup.yml
```

```bash
./configure.yml
```

## TODO

1. run json.rb to update version
2. run preseed and fill in all values with variables
3. remove hard coded values from image.yml

### Notes

- Builds a Vagrant box from an ISO through multiple stages for any number of OS flavors and versions
- All commands are executed and build artifacts generated relative to the OS flavor/version directory
- The .gitignore excludes all build artifacts so they are not committed to the repo
- Each builder has a bash script that takes vars and calls the packer builder in the subdirectory flavor/version/builds
- Builders other than base just take an image from a previous builder and apply ansible provisioning found in provision.yml
- In the base directory is provision.yml which has a host stanza for each builder type which applies the roles to the image


## Usage

All examples will build off of a debian stretch ISO image in the debian/stretch directory.

### Build a Base System

#### Build from an ISO

'iso' is the only keyword parameter. parameters to all other commands are user defined.
'iso' causes the build to originate from the distribution's ISO available on the internet

```bash
./prepd packer iso debian/stretch base
```

This will:

- Install vagrant user and insecure private key
- Install the VBoxGuestAdditions.iso
- Provision the machine using Ansible and the playbook ./provision.yml
- Output a .vmdk and .ovf file in the ./images/base directory
- Output a VirtualBox .box file in the ./boxes directory

#### Test the machine in Virutal Box

```bash
vagrant up
vagrant up --provision
```

NOTE: When starting the machine the Vagrantfile will prompt to remove the .vagrant directory and
the cache in ~/.vagrant.d/boxes/box_name
It is important to remove these directories if you want to ensure the machine is clean. When done, run:

```bash
vagrant destroy
```


### Build a Developer System

After creating the base system artifiact, can now derive new boxes from that.

#### Import from the Base System

This example will import the base image, provision the image using Ansible for the 'developer' role and output a vagrant box named 'developer'

```bash
./build base developer
```

The output will be:
- a VirtualBox .box file in ./boxes that has been provisioned with the 'developer' role in provision.yml
- an image in ./images/developer to use as a base image to derive further images


#### Update an Image and Box

It can be useful to update an existing image/box. The rebuild bash script applies the ansible role to the existing image and creates a new box
To update the 'developer' image with Ansible tasks in provision.yml:

```bash
./rebuild developer
```

This will build a new image in ./images/developer and a box in ./boxes and push it to S3


#### Push Box to AWS S3

This process uses the s3 builder and pushes the box artifiact to S3. The s3 builder:

- Rebuilds the image to ./images/developer and box to boxes
- Uploads the box to S3

To start, create a credentials file in ~/.aws/credentials OR export your AWS credentials:

```bash
export AWS_ACCESS_KEY_ID=YOUR_AWS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET
```

Next, configure the push-s3 script with your bucket name and region:

```bash
export S3_BUCKET=my-storage-bucket
export S3_REGION=us-east-1
```

Finally, build and push the image:

```bash
./push-s3 developer
```

That's it! The box is now available on S3. It will be availble from a URL such as:

https://s3-ap-southeast-1.amazonaws.com/c2p4-storage/boxes/0.0.1/debian-stretch-amd64-developer.box

For more details, see the [vagrant-s3 plugin documentation](https://github.com/lmars/packer-post-processor-vagrant-s3)


## Clean Up

In order to save space you can safely delete the output directories. In the root of the project, execute:

```bash
./clean.sh
```
