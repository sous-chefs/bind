# Cookbook testing

This document describes the test process for this cookbook.

## Pre-requisites

Before starting with testing you will need:

* A working ChefDK install
* Docker and kitchen-dokken for integration testing

## Continuous Integration

Tests are run automatically
by [Travis CI](https://travis-ci.org/joyofhex/cookbook-bind) whenever a new
PR is opened.

## Linting and Style Checks

This cookbook uses cookstyle and foodcritic for automated checking of style.

You can run this locally with:

```
rake lint
```

## Unit testing

We use chefspec to provide unit testing for the cookbook. This can be run
as follows:

```
rake unit
```

## Integration Tests

This cookbook has some simple integration tests which are run via test-kitchen.

They will verify that the default recipe and custom resources can provide a
working nameserver.

You can run the full set of integration tests with the following command:

```
rake integration
```

By default this will run with chef-client 12. To use a different version set
the `CHEF_VERSION` environment variable.

You can run a subset or specific test (such as all CentOS 7 builds) using
the following syntax:

```
rake integration[centos-7]
```
