# setup

Ros environment has a number of dependencies. This repository of anisble roles exists to make setting up the environment easier, quicker and more productive

This setup has been tested with a Debian 9.9 Vagrant box. If you are running on Mac please note any issues 

## Automated Setup

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

### Install Platform Dependenices

Use ansible to install Postgres, Redis, Node, Ruby, Docker, docker-compose, etc

```bash
./backend.yml
```

If successful all the necessary services will have been installed and configured.
In order to run the ros-cli in development mode you need to source some environment value like so:

```bash
source ~/.profile
ros --version
```

If all is well you should see the current version of the ros CLI output

## Initialize an Existing Project

After cloning the project, first generate a local environment.
After that, run the preflight check which reports if there is a valid environment for the platform.
This includes whether the ros services repo exists at $PROJECT_HOME/ros

```bash
git clone your_project_url
cd project_dir
ros g env local
ros preflight:check
```

All values of the preflight check should be 'ok'. If any are not then you can run `ros preflight:fix` to fix them

After a successful preflight check you can build and test a service

### Build and Initialize the IAM Service

First, build the image

```bash
ros build iam
```

After building the image, run the database migrations for the iam service

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
ros build
```

Initialize the service databases and see them with test data:

```bash
ros ros:db:reset:seed
```

### Bring up the Platform and Test Connection

Start all services

```bash
ros up -d

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

Copy and paste the postman config for Admin-2 into Postman and set the server to `http://localhost:3000`

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

### Run console mode

Console mode is just running the services as independent rails applications. There are no services running.
The minimum requirements for console mode are Postgres and Redis

### Run local mode

Local mode is running all the services as containers using docker-compose to manage them.
The minimum requirements for local mode are docker and compose

Install Postgres, redis, docker, docker-compose, node and ruby via rbenv
