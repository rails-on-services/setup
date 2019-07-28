A Ros project has a lot of moving parts.
To save time on setup, we recommend working in a virtual machine environment for development.
This repository, which consists of a vagrant config, setup scripts and anisble roles, sets up that environment.

This setup has been tested with a Debian 9.9.1 Vagrant box.
If you run these scripts on a Mac and encouter a problem or anything here doesn't work as expected plese create a GH issue

## Virtual Machine Setup

### Setup Vagrant and VirtualBox on MacOS

Make sure you have Vagrant and VirtualBox on your machine by running `vagrant -v` and `VirtualBox --help`.
If you don't have them, use the following commands to install them with `homebrew`:

```bash
brew cask install virtualbox
brew cask install vagrant
``` 

### Setup Project and VM

Make a directory for the project on your local machine:

```bash
mkdir [project-name]
cd [project-name]
```

This directory will be shared between the host and the VM

Start your ssh agent, download the Vagrantfile and bring up the VM:

```bash
ssh-add
curl https://raw.githubusercontent.com/rails-on-services/setup/master/Vagrantfile > Vagrantfile
vagrant up
```

NOTE: It is required to have your ssh agent running or have a copy of your ssh private key installed into the VM

### Setup Vagrant and VirtualBox on Windows

TODO

## Verify VM Configuration

**All subsequent commands are executed in the VM**

ssh to the VM and verify that your ssh agent is running:

```bash
vagrant ssh
ssh-add -l
```

You should see output similar to the following:

`2048 SHA256:NFiBekaQuGIwvS+t8VB2iHtAJGUx/skJlfJ6VTHPj80 /Users/roberto/.ssh/id_rsa (RSA)`

Verify that docker is setup properly:

```bash
docker ps
```

You should see an empty docker images list similar to below. Any error message indicates a misconfigured environment.

```bash
CONTAINER ID   IMAGE   COMMAND   CREATED   STATUS   PORTS 
```

Verify that the ros cli is available:

```bash
ros version
```

If all is well you should see the current version of the ros CLI output

The VM is now ready to go. Let's get started!


## Working with an Existing Project

**All commands are executed in the VM**

### Initialize the Project

Clone your project:

```bash
vagrant ssh
cd [project-name]
git clone [project-url]
cd [project-dir]
```

Initialize the project:

```bash
ros be init
```

This command checks dependencies and configures the environment as required.
It also outputs a list the state of platform requirements.
All values of the output should be 'ok' as shown here:

```bash
vagrant@perx:~/perx/whistler$ ros be init
ros repo: ok
environment configuration: ok
```


### Build and Run the IAM Service

After a successful initialization, build and test a single service:

```bash
ros be up -d iam
```

This will pull and run multiple images, including postgres, redis, nginx and iam

The database migrations will run automatically on the iam service on first boot

Once the service is running and migrations are completed the process will output seed credentials
and the platform status:

```bash
Postman:
{"name"=>"111111111-root", "values"=>[{"key"=>"authorization", "value"=>"Basic AORCPRMDDZTZWGCGRUMN:rPTxv3vQ8yPdr64cAsOmwIjdEg7A-n3iTw51sZCKlgaggtsllG0ZGw"}, {"key"=>"email", "value"=>"root@platform.com"}, {"key"=>"password", "value"=>nil}]}
{"name"=>"222222222-root", "values"=>[{"key"=>"authorization", "value"=>"Basic ASFEWJBEPPXCRHQNFTTF:Xx3icVkWGcgyv6MIIwWjFif5fPksf7l60Q7Q5-8IO8_8dWc9rOKY2A"}, {"key"=>"email", "value"=>"root@client2.com"}, {"key"=>"password", "value"=>nil}]}
{"name"=>"222222222-Admin_2", "values"=>[{"key"=>"authorization", "value"=>"Basic AAHYLJEKHJFQFLFEKHKB:yGoJ_01ngtEga4RvsBSm3YPEGAo22hqa94IMwlnuLaDioKFLKhtjhA"}, {"key"=>"username", "value"=>"Admin_2"}, {"key"=>"password", "value"=>nil}]}

Envs:
PLATFORM__TENANT__1__ROOT__1=Basic AORCPRMDDZTZWGCGRUMN:rPTxv3vQ8yPdr64cAsOmwIjdEg7A-n3iTw51sZCKlgaggtsllG0ZGw
PLATFORM__TENANT__2__ROOT__2=Basic ASFEWJBEPPXCRHQNFTTF:Xx3icVkWGcgyv6MIIwWjFif5fPksf7l60Q7Q5-8IO8_8dWc9rOKY2A
PLATFORM__TENANT__2__USER__1=Basic AAHYLJEKHJFQFLFEKHKB:yGoJ_01ngtEga4RvsBSm3YPEGAo22hqa94IMwlnuLaDioKFLKhtjhA

Cli:
[111111111-root]
ros_access_key_id=AORCPRMDDZTZWGCGRUMN
ros_secret_access_key=rPTxv3vQ8yPdr64cAsOmwIjdEg7A-n3iTw51sZCKlgaggtsllG0ZGw

[222222222-root]
ros_access_key_id=ASFEWJBEPPXCRHQNFTTF
ros_secret_access_key=Xx3icVkWGcgyv6MIIwWjFif5fPksf7l60Q7Q5-8IO8_8dWc9rOKY2A

[222222222-Admin_2]
ros_access_key_id=AAHYLJEKHJFQFLFEKHKB
ros_secret_access_key=yGoJ_01ngtEga4RvsBSm3YPEGAo22hqa94IMwlnuLaDioKFLKhtjhA



Platform Services    Status                   Core Services        Status                   Infra Services       Status
----------------------------------------------------------------------------------------------------------------------------
                                              account              Not Enabled              fluentd              Not Enabled
                                              billing              Not Enabled              localstack           Running
                                              cognito              Stopped                  nginx                Running
                                              comm                 Stopped                  postgres             Running
                                              iam                  Running                  redis                Running
                                              storage              Stopped                  sftp                 Stopped

*** Services available at https://api.ros.rails-on-services.org ***
*** API Docs available at [TO IMPLEMENT] ***
```

Check under Core Services that the iam service has Status running

Occationally on first migrations there is an error message like:

```bash
rails aborted!
PG::ConnectionBad: could not connect to server: Connection refused
        Is the server running on host "postgres" (172.18.0.3) and accepting
        TCP/IP connections on port 5432?
```

If you see this, just re-run the command `ros be up -d iam` Sometimes the database container isn't ready


### Connect to the IAM Console

Connect to the service's rails console:

```bash
ros be c iam
```

You should see something similar to the following output:

```bash
Loading development environment (Rails 6.0.0.rc1)

Frame number: 0/22

Model Shortcut Console Commands:
Model               Class  All     Create  First   Last    Pluck
Group               g      ga      gc      gf      gl      gp
Policy              p      pa      pc      pf      pl      pp
PolicyAction        pa     paa     pac     paf     pal     pap
Root                r      ra      rc      rf      rl      rp
Tenant              t      ta      tc      tf      tl      tp
User                u      ua      uc      uf      ul      up
UserGroup           ug     uga     ugc     ugf     ugl     ugp

Type `help ros` for additional console commands

[1] [iam][development][public] pry(main)>
```

The Model Shortcut commands are convenience methods for accessing and creating objects

In the rails console type `st` (shortcut for switch-tenant). If the database was seeded correctly you should see output like below with two test tenants `111_111_111` and `222_222_222`

```bash
[1] [iam][development][public] pry(main)> st
   (0.7ms)  SELECT "public"."tenants"."id", "public"."tenants"."schema_name", "public"."tenants"."name" FROM "public"."tenants" ORDER BY "public"."tenants"."id" ASC
   1 111_111_111 Account
   2 222_222_222 Account
   [2] [iam][development][public] pry(main)>
```

Disconnect from the rails console

```bash
<ctrl>+d
```

### Test the IAM Server

To access the server you will need valid credentials. In a previous step the credentials were displayed. If you need to show them again
 you can type

```bash
ros be credentials
```

The first few lines of output will look similar to this:

```bash
Postman:
{"name"=>"111111111-root", "values"=>[{"key"=>"authorization", "value"=>"Basic AORCPRMDDZTZWGCGRUMN:rPTxv3vQ8yPdr64cAsOmwIjdEg7A-n3iTw51sZCKlgaggtsllG0ZGw"}, {"key"=>"email", "value"=>"root@platform.com"}, {"key"=>"password", "value"=>nil}]}
{"name"=>"222222222-root", "values"=>[{"key"=>"authorization", "value"=>"Basic ASFEWJBEPPXCRHQNFTTF:Xx3icVkWGcgyv6MIIwWjFif5fPksf7l60Q7Q5-8IO8_8dWc9rOKY2A"}, {"key"=>"email", "value"=>"root@client2.com"}, {"key"=>"password", "value"=>nil}]}
{"name"=>"222222222-Admin_2", "values"=>[{"key"=>"authorization", "value"=>"Basic AAHYLJEKHJFQFLFEKHKB:yGoJ_01ngtEga4RvsBSm3YPEGAo22hqa94IMwlnuLaDioKFLKhtjhA"}, {"key"=>"username", "value"=>"Admin_2"}, {"key"=>"password", "value"=>nil}]}
```

Copy the last line of the postman config for `Admin-2` and import it into Postman

Set the imported config as the current environment

Set the request `Authorization` header to `{{authorization}}`

Then make a request to `http://localhost:3000/iam/users`

If it is working you will see results like this:

![Alt text](/assets/postman_iam.png?raw=true "Response from IAM Service")


### Build and Run the Remaining Services

To build the rest of the service images:

```bash
ros be up -d
```

Verify the services are running:

```bash
ros be status
```

You should see something similar to the following output:

```bash

Platform Services    Status                   Core Services        Status                   Infra Services       Status
----------------------------------------------------------------------------------------------------------------------------
                                              account              Not Enabled              fluentd              Not Enabled
                                              billing              Not Enabled              localstack           Running
                                              cognito              Running                  nginx                Running
                                              comm                 Running                  postgres             Running
                                              iam                  Running                  redis                Running
                                              storage              Running                  sftp                 Stopped

*** Services available at https://api.ros.rails-on-services.org ***
*** API Docs available at [TO IMPLEMENT] ***
```

That's it for setting up a projet

## Deploy Project into Kubernetes

The default configurations for test and production environments are to deploy the project into a Kubernetes cluster

### Setup

#### Credentials

* Add your target cloud credentials. For AWS this is a file located at `~/.aws/credentials`

* Add your docker credentials for your specific image repository. The file is located at `~/.docker/config.json`


#### EKS Cluster Authentication

See your AWS Kubernetes admininistrator for authentication details.

It could be either short form: `aws eks update-kubeconfig --name {{ cluster_name }}`

Or the long form, which adds `--role-arn arn:aws:iam::{{ aws_account_id }}:role/{{ aws_role_name }}` to the command

To run the short form:

```bash
cd [project-name]/[project-dir]
ROS_ENV=test ros be init
```

To run the long form add the `-l` switch:

```bash
cd [project-name]/[project-dir]
ROS_ENV=test ros be init -l
```

If the command succeeded you should see output similar to:

```bash
aws eks update-kubeconfig --name develop --role-arn arn:aws:iam::814127428874:role/eks-admin
Added new context arn:aws:eks:ap-southeast-1:978123428748:cluster/develop to /home/vagrant/.kube/config
kubectl cluster-info
Kubernetes master is running at https://DSFADS83KASDDF993KKADF99B1FE0CED.sk1.ap-southeast-1.eks.amazonaws.com
CoreDNS is running at https://DSFADS83KASDDF993KKADF99B1FE0CED.sk1.ap-southeast-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

### Deploy

Before running these tasks make sure you have valid credentials in the VM at ~/.aws/credentials

```bash
cd [project-name]/[project-dir]
ros be g env test
ROS_ENV=test ros be init
ROS_ENV=test ros be up
```

**Your mircoservices project is now running in Kubernetes!**

Follow the [steps](#test-the-iam-server) for testing the IAM server at the endpoint displayed after running `ROS_ENV=test ros up`


## Create a New Project

```bash
ros new project_name
cd project_name
ros be init
ros be up -d
ros be credentials
```

## Services

### Create a New Service

```bash
cd project_root
ros be g service service_name
cd services/service_name
rails ros:db:reset:seed
rails g endpoint [endpoint_name] [*model_attributes]
```

Exmaple create a reward service with a campaign model

```bash
ros be g service reward
cd services/reward
rails ros:db:reset:seed
rails g endpoint campaign name description properties:jsonb display_properties:jsonb
```

## Miscellaneous

```bash
ros be up iam --seed
```

### Configuration with Kubernetes

#### Install devops tools

The required tools are awscli, EKS authtenitcator, skaffold, vault, terraform, helm and kubectl

These tools are already installed on the VM, but you can re-install them by running the `devops.yml` ansible script.

NOTE: You can change the version of each of the tools by editing `./devops-vars.yml` before running the below commands

```bash
cd ~/[project-name]/ros/setup
./devops.yml
```


## Run console mode

Console mode is just running the services as independent rails applications. There are no services running.
The minimum requirements for console mode are Postgres and Redis
