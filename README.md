# setup

Ros environment has a number of dependencies. This repository of anisble roles exists to make setting up the environment easier, quicker and more productive

This setup has been tested with a Debian 9.9 Vagrant box. If you are running on Mac please note any issues 

## Automated Setup

### Vagrant Box

Make a directory for the project on your local machine and place the Vagrantfile in the root of this reposiotry in that directory.

```bash
mkdir dev
cd dev
curl https://raw.githubusercontent.com/rails-on-services/setup/master/Vagrantfile
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

After cloning the project, you can run the preflight check which reports if there is a valid environment for the platform.
This includes whether the ros services repo exists at $PROJECT_HOME/ros

```bash
git clone your_project_url
cd project_dir
ros preflight:check
```

All values of the preflight check should be 'ok'. If any are not then you can run `ros preflight:fix` to fix them

After a successful preflight check you can build the images.

```bash
ros build
```

After building you can run the database migrations for each service

```bash
ros db:reset:seed
```

And now, start the servers:

```bash
ros s
```

Display credentials:

```bash
ros credentials:show
```


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
