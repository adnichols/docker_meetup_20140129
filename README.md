# Docker meetup 1/29/2014

## How do we use Docker?

Right now docker is used for testing cookbooks during development. We
use test-kitchen + the kitchen-docker driver to speed iteration on
cookbooks. 

## Reasons for using Docker?

- __Speed__, container creation time is nearly instant & we can converge on
  bare metal instead of using virtualization. Cuts down compile times,
  package installs or any CPU/IO intensive operations. 
- __Image cache__, we can add pre-testing provisioning steps to VM systems
  to do things like install chef, which are then loaded from cache and
  take almost no time to execute. 
- __Remote Converge__. Converge can be kicked off from a remote
  workstation but runs on a system on the corporate network. Packages are 
  downloaded to the docker host, not your workstation. 
- __Centralized__. We can inspect containers which have been run either
  in CI or from workstations, kill off orphan containers, etc. This
  becomes useful when cookbook converges involve connections to databases
  and other systems that you may want to kill off. 

Did I mention speed?

## Our cookbook testing workflow

We are (or try to be) a TDD (Test Driven Development) shop even when it
comes to cookbook development. This means we are often writing tests &
then running those tests to validate the code we add works. This means
LOTS of cookbook converges. 

Typical workflow is like this:

- clone cookbook, add a test for new functionality
- If adding unit tests run `rake unit` until passing & iterate
- If adding integration tests run `rake integration` to ensure it converges 
  and tests pass (uses docker)
- Once tests are passing, `git push`
- CI environment pulls down changes and runs all tests inside either
  docker or vagrant depending on cookbook configuration
- If tests pass, git tag is created for version & cookbook is uploaded
  to hosted chef. If fail, build is marked as failed and our Build light
  turns red - any single cookbook failure turns the light red. 
- Version is incremented & pushed to repository to be ready for next
  release.

## Interesting features of kitchen-docker driver

The [kitchen-docker](https://github.com/portertech/kitchen-docker) driver is 
what allows test-kitchen to use docker for converging cookbooks for testing. 

Features

- Uses docker-api gem so you don't need the docker CLI tools
- Has support for:
  - local or remote docker instance 
  - provisioning commands which add layers to docker image cache
  - custom images, ubuntu & centos supported by default
  - privileged mode
  - port forwarding
  - Volume creation
  - specifying hostname
  - specifying DNS
  - Defining the run_command (defaults to sshd)
  - memory / cpu limits

Adding to your cookbook is as easy as adding to your Gemfile:

Gemfile:
```
gem 'kitchen-docker', :github => 'portertech/kitchen-docker'
```

## Enabling docker in a cookbook

We presently make use of the `.kitchen.local.yml` to enable docker in
our cookbooks. This makes it simple for someone to disable docker (just
move that file to another name). We are looking forward to the next
release of test-kitchen which should allow us to [set an environment
variable](https://github.com/test-kitchen/test-kitchen/pull/306) to
point to a particular kitchen config.

A typical `.kitchen.local.yml` will look like this:

```
---
driver_plugin: docker
driver_config:
  use_sudo: true
  image: centos
  socket: tcp://somedockerhost:4243
  provision_command:
    - 'curl -L https://www.opscode.com/chef/install.sh | bash'
    - 'yum -y install make gcc which bash tar cronie'
```

This simply overrides the options in `.kitchen.yml` where necessary to
enable docker

## Docker caveats

There are a few gotchas we've run into using Docker for cookbook
development - some can be overcome, others not. 

- If you have a cookbook that needs to edit `/etc/resolv.conf` or
  `/etc/hosts`, Docker is probably not a good choice. 

See: https://github.com/dotcloud/docker/issues/2267

- There are a variety of packages and files which do not exist in the
  default public images for things like centos such as:
  - /etc/sysconfig/network
  - the `which` binary
  - some /dev directories are missing such as /dev/fd

Most of these can be overcome using the kitchen-docker provisioning
commands - here is a list of typical things we might have in the
`provision_command:` section of a `.kitchen.local.yml`:

```
provision_command:
  - "curl -L https://www.opscode.com/chef/install.sh | /bin/bash"
  - "yum -y install unzip make gcc rsync which"
  - "ln -s /proc/self/fd /dev/fd"
  - "touch /etc/sysconfig/network"
```

#### But you can also do some cool stuff

We recently ran into a problem with chef-zero which was fixed in the
chef-zero gem, but because we install the omnibus chef package, we would
have to wait for a new omnibus release to get the fix. With docker we
could just update the chef-zero gem with a config like this:

```
  provision_command:
  - "curl -L https://www.opscode.com/chef/install.sh | /bin/bash"
  - "/opt/chef/embedded/bin/gem install chef-zero --version '~> 1.7.0'"
```
Whalla - now we have the updated chef-zero gem without a new chef
release. 
