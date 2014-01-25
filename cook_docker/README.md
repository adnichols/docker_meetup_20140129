## Description

This is a sample cookbook used to demonstrate how we enable docker
support for testing cookbooks at Rally Software for the Boulder Docker
meetup on 1/29/2014

### Dependencies

The setup for this cookbook depends on Rally's
[cookbook-development](https://github.com/RallySoftware-cookbooks/cookbook-development)
project which provides a number of helpers for making cookbook
development easier. 

This makes use of the following tools:

- [test-kitchen](https://github.com/test-kitchen/test-kitchen)
- [chefspect](https://github.com/sethvargo/chefspec/)
- [foodcritic](http://acrmp.github.io/foodcritic/)
- [kitchen-docker](https://github.com/portertech/kitchen-docker)
- [docker](http://www.docker.io)

Of these, only kitchen-docker is in the Gemfile for this cookbook, all
other dependencies are in the gemspec for cookbook-development. 

You can look at the `.kitchen.yml` and .kitchen.local.yml` for
information about how test-kitchen is configured to run integration
tests.

### Usage

To run this cookbook:
1. Clone this repository
2. Run `bundle install`
3. Run `bundle exec rake test` to perform all tests
4. Run `bundle exec rake unit` to perform unit tests
5. Run `bundle exec rake integration` to perform integration tests

Or to just use test-kitchen without integrated rake tasks
1. Run `kitchen converge` to converge the system
2. Run `kitchen verify` to perorm integration tests

### What is different about this cookbook?

Compared to the default cookbook structure this has the following
additions:
- unit/integration tests are in `test` directory
- Gemfile added which includes
  [cookbook-development](https://github.com/RallySoftware-cookbooks/cookbook-development)
- .kitchen.yml added which configures test-kitchen
- .kitchen.local.yml added which adds docker configuration
- Berksfile added which defines berks configuration
- metadata.rb loads VERSION file for version increments

## License
Copyright (C) 2014 Rally Software Development Corp

Distributed under the MIT License.
