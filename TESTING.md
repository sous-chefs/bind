# Cookbook testing

This document describes the test process for this cookbook.

## Pre-requisites

Before starting with testing you will need:

* A working ChefDK install
* Vagrant and Virtualbox installed for integration testing

## Continuous Integration

The linting, style, and unit tests are run automatically
by [Travis CI](https://travis-ci.org/joyofhex/cookbook-bind) whenever a new
PR is opened.

## Linting and Style Checks

This cookbook uses cookstyle and foodcritic for automated checking of style.

You can run this locally with:

```
chef exec foodcritic .
chef exec cookstyle
```

## Unit testing

We use chefspec to provide unit testing for the cookbook. This can be run
as follows:

```
chef exec rspec
```

## Integration Tests

This cookbook has some simple integration tests which are run via test-kitchen.

They will verify that the default recipe and custom resources can provide a
working nameserver.

To verify the default recipe is working use:

```
chef exec kitchen test default
```

To verify custom resources are working correctly use:

```
chef exec kitchen test resource
```

These are not run automatically by Travis CI.
