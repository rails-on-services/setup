# setup

Ros environment has a number of dependencies. This repository of anisble roles exists to make setting up the environment easier, quicker and more productive

This setup has been tested with a Debian 9.9 Vagrant box. If you are running on Mac please note any issues 

## Automated Setup

### Setup Vagrant and VirtualBox

Make sure you have Vagrant and VirtualBox on your machine by running `vagrant -v` and `VirtualBox --help`.
If you don't have them, install it, below commands for installing it with `homebrew`:

```bash
brew cask install virtualbox
brew cask install vagrant
``` 

### Vagrant Box

Make a directory for the project on your local machine and place the Vagrantfile in the root of this reposiotry in that directory.

```bash
mkdir dev
cd dev
curl https://raw.githubusercontent.com/rails-on-services/setup/master/Vagrantfile > Vagrantfile
```

Make sure your ssh agent is running, bring up the vagrant box and connect to it

```bash
ssh-add
vagrant up
vagrant ssh
```

Verify that your ssh agent is installed

```bash
ssh-add -l
```

You should see output similar to the following:

`2048 SHA256:NFiBekaQuGIwvS+t8VB2iHtAJGUx/skJlfJ6VTHPj80 /Users/roberto/.ssh/id_rsa (RSA)`


### Clone this repo and run setup

This procedure will install ansible so it can be used to further configure the machine

```bash
sudo apt install git --yes
git clone https://github.com/rails-on-services/setup.git
cd setup
./setup.sh
```

### Install Platform Dependencies

Use ansible to install Postgres, Redis, Node, Ruby, Docker, docker-compose, etc

```bash
./backend.yml
```

If successful all the necessary services will have been installed and configured.

In order for your linux user to access docker you need to refresh you user's group membership. It can be done with this command:

```bash
exec sudo su -l $USER
```

Confirm that the environment is setup properly.

```bash
docker ps
```

Yuo should see an empty docker images list similar to below. Any error message indicates a misconfigured environment.

```bash
CONTAINER ID   IMAGE   COMMAND   CREATED   STATUS   PORTS 
```

Check that the ros cli is configured:

```bash
ros --version
```

If all is well you should see the current version of the ros CLI output


## Initialize an Existing Project

Follow these steps

1. Clone the project
2. generate a local environment
3. run the preflight check

```bash
vagrant ssh
cd dev
git clone your_project_url
cd project_dir
ros g env local
ros preflight:check
```

The preflight check generates a report listing the state of platform requirements which includes whether the ros services repo exists at $PROJECT_HOME/ros.
All values of the preflight check should be 'ok'. If any are not then you can run `ros preflight:fix` to fix them

### Build and Initialize the IAM Service

After a successful preflight check build and test a single service. 

First let's build `nginx` container 
(should be done only once per configuration):

```bash
ros up -d nginx
```

Second, build `iam` image:

```bash
ros build iam
```

After building the image, run the database migrations for the iam service:

```bash
ros ros:db:reset:seed iam
```

Occationally on first migrations there is an error message like:

```bash
rails aborted!
PG::ConnectionBad: could not connect to server: Connection refused
        Is the server running on host "postgres" (172.18.0.3) and accepting
        TCP/IP connections on port 5432?
```

If you see this, just re-run the command. Sometimes the database container isn't ready

Bring up the IAM Service:

```bash
ros up -d iam
```

Verify the IAM Service is running:

```bash
ros ps
```

You should see something similar to the following output:

```bash
        Name                       Command               State                            Ports
-----------------------------------------------------------------------------------------------------------------------
whistler_iam_1          bundle exec rails server - ...   Up       0.0.0.0:32770->3000/tcp
```


### Build and Iniailize Remaining Services

To build the rest of the service images:

```bash
ros up -d nginx
ros build
```

Initialize the service databases and see them with test data:

```bash
ros ros:db:reset:seed
```

### Bring up the Platform and Test Connection

Start all services

```bash
ros up nginx -d
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

To test the connection to the IAM Service, first display the credentials:

```bash
ros ros:iam:credentials:show
```

Copy and paste the postman config for `Admin-2` into Postman and set the server to `http://localhost:3000`

Then make a request to `http://localhost:3000/iam/users`


## Create a New Project

```bash
ros new name
```

## Manual Setup

This is basically an outline of what the ansible playbooks do:

First, the ruby version of project must be installed on the machine. After that you need to:

Clones the ros-cli repo
Runs bundle install to install the CLI's dependencies
Sets RUBYLIB to location of ros-cli/lib
Adds ros-cli/exe directory to PATH

# Services

## Create a New Service

```bash
cd project_root
ros g service service_name
cd services/service_name
rails ros:db:reset:seed
rails g endpoint endpoint_name model_attributes
```

Exmaple create a reward service with a campaign model

```bash
ros g service reward
cd services/reward
rails ros:db:reset:seed
rails g endpoint campaign name description properties:jsonb display_properties:jsonb
```


### Run console mode

Console mode is just running the services as independent rails applications. There are no services running.
The minimum requirements for console mode are Postgres and Redis

### Run local mode

Local mode is running all the services as containers using docker-compose to manage them.
The minimum requirements for local mode are docker and compose

Install Postgres, redis, docker, docker-compose, node and ruby via rbenv
