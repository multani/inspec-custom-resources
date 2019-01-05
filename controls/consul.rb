consul_http_addr = attribute('consul_http_addr')
minimum_servers = attribute('minimum_servers')
datacenter = attribute('datacenter')

control 'consul-cluster' do
  title 'Verify the Consul cluster configuration'
  desc 'The Consul cluster should be up and running'

  describe consul_cluster(consul_http_addr) do
    it { should have_leader }
    its('servers_count'){ should be >= minimum_servers }
    its('datacenters'){ should include datacenter }
  end
end
