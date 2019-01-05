Custom resources for [InSpec](https://www.inspec.io/)
=====================================================

This is a work in progress to create new InSpec resources.

See [`libraries`](libraries) for the implementation of the resources,
[`controls`](controls) for an example on how the new resources can be used.

This currently provides:

* a [`consul_cluster`](libraries/consul.rb) resource, to check the configuration of
  [Consul](https://consul.io) cluster.


Testing
-------

You can test the Consul resource with Docker Compose:

* Run [Ruby Bundler](https://bundler.io/): `bundle install`
* Start the Consul Docker containers: `docker-compose up -d`
* Run the InSpec profile with Bundler, which should fail: `bundle exec inspec exec .`
* Join all the Consul agents: `docker-compose exec consul0 consul join consul1 consul2`
* Run the InSpec profile again, this time it should work: `bundle exec inspec exec .`
