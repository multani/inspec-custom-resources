Custom resources for [InSpec](https://www.inspec.io/)
=====================================================

This is a work in progress to create new InSpec resources.

See [`libraries`](libraries) for the implementation of the resources,
[`controls`](controls) for an example on how the new resources can be used.

This currently provides:

* a [`consul_cluster`](libraries/consul.rb) resource, to check the configuration of
  [Consul](https://consul.io) cluster.
