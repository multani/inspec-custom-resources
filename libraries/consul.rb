class ConsulCluster < Inspec.resource(1)
  name 'consul_cluster'
  desc 'Test the configuration of a Consul cluster'
  example "
    describe consul_cluster('http://localhost:8500') do
      it { should be_reachable }
      it { should have_leader }
      it { should be_allowed_to_list_acls}
      its('servers_count'){ should be >= 3 }
      its('datacenter'){ should include 'dc1' }
    end
  "

  def initialize(url, token)
    @url = url
    @headers = {'x-consul-token': token}

    query = inspec.http(url)
    begin
      status = query.status()
    rescue => e # something wrong happened while checking the HTTP status
      fail_resource("Consul cluster unreachable: #{e}")
    end
  end

  def has_leader?
    http_json("#{@url}/v1/status/leader") != ''
  end

  def allowed_to_list_acls?
      query = inspec.http("#{@url}/v1/acl/list", headers: @headers)
      query.status == 200
  end

  def servers_count
    members = http_json("#{@url}/v1/agent/members")

    servers = 0
    members.each do |member|
      servers += 1 unless member['Tags']['role'] != 'consul' or member['Status'] != 1
    end
    servers
  end

  def datacenters
    http_json("#{@url}/v1/catalog/datacenters")
  end

  def to_s
    "Consul at #{@url}"
  end

  def method_missing(name)
    @params[name.to_s]
  end

  private

  def http_json(url)
    query = inspec.http(url)
    if query.status != 200
      raise Inspec::Exceptions::ResourceFailed, "Consul query on #{url} return HTTP code #{query.status}"
    end

    begin
      require 'json'
      JSON.parse(query.body)
    rescue => e
      raise Inspec::Exceptions::ResourceFailed, "Unable to parse JSON from Consul query on #{url}: #{e.message}"
    end
  end
end
