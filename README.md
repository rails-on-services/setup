# setup

Ros environment has a number of dependencies. This repository of anisble roles exists to make setting up the environment easier, quicker and more productive

This setup has been tested with a Debian 9.9 Vagrant box. If you are running on Mac please note any issues 

## Automated Setup

### Vagrant Box

Put this into a Vagrantfile

```bash
Vagrant.configure("2") do |config|
  config.vm.box = "debian/stretch64"
  config.vm.network "forwarded_port", guest: 3000, host: 3000
end
```

Start the box and connect to it:

```bash
vagrant up
vagrant ssh
```

### Clone this repo and run setup

This procedure will install ansible so it can be used to further configure the machine

```bash
git clone https://github.com/rails-on-services/setup.git
cd setup
./setup.sh
```

### Install Platform Dependenices

Use ansible to install Postgres, Redis, Node, Ruby, Docker, docker-compose, etc

```bash
./backend.yml
```

If successful all the necessary services will have been installed and configured

## Manual Setup

This is basically an outline of what the ansible playbooks do:

[]min reqs for local are docker and compose
[]min reqs for console are pg and redis and ruby version of project

Install Postgres, redis, docker, docker-compose, node and ruby via rbenv

Clones the ros-cli repo
Runs bundle install to install the CLI's dependencies
Sets RUBYLIB to location of ros-cli/lib
Adds ros-cli/exe directory to PATH

## Initialize an Existing Project

After cloning the project, you can run the preflight check which reports if there is a valid environment for the platform.
This includes whether the ros services repo exists at $PROJECT_HOME/ros

```bash
git clone your_project_url
cd project_dir
ros preflight:check
```

All values of the preflight check should be true. If any are not then you can run `ros preflight:fix` to fix them

After a successful preflight check you can run ros server with -b switch (build images) and -i switch (to initialize service databases)

```bash
ros s -b -i
```


## Create a New Project

```bash
ros new name
```
