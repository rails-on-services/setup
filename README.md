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

Preflight the project:

```bash
ros preflight
```

This command checks dependencies and configures the environment as required.
It also outputs a list the state of platform requirements.
All values of the preflight should be 'ok' as shown here:

```bash
vagrant@perx:~/perx/whistler$ ros preflight
ros repo: ok
environment configuration: ok
```


### Build and Run the IAM Service

After a successful preflight check, build and test a single service:

```bash
ros up -d iam
```

This will pull and run multiple images, including postgres, redis, nginx and iam

The database migrations will run automatically on the iam service on first boot

Occationally on first migrations there is an error message like:

```bash
rails aborted!
PG::ConnectionBad: could not connect to server: Connection refused
        Is the server running on host "postgres" (172.18.0.3) and accepting
        TCP/IP connections on port 5432?
```

If you see this, just re-run the command `ros up -d iam` Sometimes the database container isn't ready

Verify the IAM Service is running:

```bash
ros ps
```

You should see something similar to the following output:

```bash
            Name                           Command               State                        Ports
-----------------------------------------------------------------------------------------------------------------------
whistler_mounted_iam_1          bundle exec rails server - ...   Up       0.0.0.0:32770->3000/tcp
whistler_mounted_localstack_1   docker-entrypoint.sh             Up       4567/tcp, 4568/tcp, 4569/tcp, 4570/tcp,
                                                                          4571/tcp, 0.0.0.0:4572->4572/tcp, 4573/tcp,
                                                                          0.0.0.0:4574->4574/tcp, 4575/tcp,
                                                                          0.0.0.0:4576->4576/tcp, 4577/tcp, 4578/tcp,
                                                                          4579/tcp, 4580/tcp, 4581/tcp, 4582/tcp,
                                                                          4583/tcp, 4584/tcp, 4585/tcp, 4586/tcp,
                                                                          4587/tcp, 4588/tcp, 4589/tcp, 4590/tcp,
                                                                          4591/tcp, 4592/tcp, 4593/tcp, 4594/tcp,
                                                                          4595/tcp, 4596/tcp, 4597/tcp, 8080/tcp
whistler_mounted_nginx_1        nginx -g daemon off;             Up       0.0.0.0:3000->80/tcp
whistler_mounted_postgres_1     docker-entrypoint.sh postgres    Up       0.0.0.0:32769->5432/tcp
whistler_mounted_redis_1        docker-entrypoint.sh redis ...   Up       0.0.0.0:32768->6379/tcp
whistler_mounted_wait_1         /wait                            Exit 0
```

### Test the IAM Console

Connect to the serivce's rails console:

```bash
ros c iam
```

You should see something similar to the following output:

```bash
Loading development environment (Rails 6.0.0.rc1)

Frame number: 0/16
[1] [iam][development][public] pry(main)>
```

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

Display test credentials:

```bash
ros r iam app:ros:iam:credentials:show
```

The last few lines of output will look similar to this:

```bash
Postman
{"name":"perx-111_111_111-root@platform.com","values":[{"key":"authorization","value":"Basic AQWSWVCYDIJTPTXTRSOB:9lTjpllDMOoMpnoMER-MZn1WgIJRZg51pxuuxoevhqkTUVy0pgy7Yg"},{"key":"email","value":"root@platform.com"},{"key":"password","value":"asdfjkl;"}]}
{"name":"perx-222_222_222-root@client2.com","values":[{"key":"authorization","value":"Basic AILYAAOFSENGTRDGHWPB:XEwMWjUilEmigzkcxINOSZiqW0Qhbe4BnmPPa0xPmM6_MnnpZKwlUw"},{"key":"email","value":"root@client2.com"},{"key":"password","value":"asdfjkl;"}]}
{"name":"perx-222_222_222-Admin_2","values":[{"key":"authorization","value":"Basic ACJGJSHLMQGKLHFQIAGB:o2U1Z1bOehqEHiiH-jh9Z6EGwUS2tNdm2KRUNjqNDcq_8f8iiV4f0g"},{"key":"username","value":"Admin_2"},{"key":"password","value":"asdfjkl;"}]}
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
ros up -d
```

Verify the services are running:

```bash
ros ps
```

You should see something similar to the following output:

```bash
        Name                       Command               State                            Ports
-----------------------------------------------------------------------------------------------------------------------
whistler_cognito_1      bundle exec rails server - ...   Up       0.0.0.0:32771->3000/tcp
whistler_comm_1         bundle exec rails server - ...   Up       0.0.0.0:32772->3000/tcp
whistler_iam_1          bundle exec rails server - ...   Up       0.0.0.0:32770->3000/tcp
whistler_localstack_1   docker-entrypoint.sh             Up       4567/tcp, 4568/tcp, 4569/tcp, 4570/tcp, 4571/tcp,
                                                                  0.0.0.0:4572->4572/tcp, 4573/tcp,
                                                                  0.0.0.0:4574->4574/tcp, 4575/tcp,
                                                                  0.0.0.0:4576->4576/tcp, 4577/tcp, 4578/tcp, 4579/tcp,
                                                                  4580/tcp, 4581/tcp, 4582/tcp, 4583/tcp, 4584/tcp,
                                                                  4585/tcp, 4586/tcp, 4587/tcp, 4588/tcp, 4589/tcp,
                                                                  4590/tcp, 4591/tcp, 4592/tcp, 4593/tcp, 8080/tcp
whistler_nginx_1        nginx -g daemon off;             Up       0.0.0.0:3000->80/tcp
whistler_postgres_1     docker-entrypoint.sh postgres    Up       0.0.0.0:32768->5432/tcp
whistler_redis_1        docker-entrypoint.sh redis ...   Up       0.0.0.0:32769->6379/tcp
whistler_wait_1         /wait                            Exit 0
```

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
ROS_ENV=test ros init
```

To run the long form add the `-l` switch:

```bash
cd [project-name]/[project-dir]
ROS_ENV=test ros init -l
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
ros g env test
ROS_ENV=test ros preflight
ROS_ENV=test ros up
```

**Your mircoservices project is now running in Kubernetes!**

Follow the [steps](#test-the-iam-server) for testing the IAM server at the endpoint displayed after running `ROS_ENV=test ros up`


## Create a New Project

```bash
ros new project_name
cd project_name
ros preflight
ros up -d
ros r iam app:ros:iam:credentials:show
```

## Services

### Create a New Service

```bash
cd project_root
ros g service service_name
cd services/service_name
rails ros:db:reset:seed
rails g endpoint [endpoint_name] [*model_attributes]
```

Exmaple create a reward service with a campaign model

```bash
ros g service reward
cd services/reward
rails ros:db:reset:seed
rails g endpoint campaign name description properties:jsonb display_properties:jsonb
```

## Miscellaneous

```bash
ros up iam --seed
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
