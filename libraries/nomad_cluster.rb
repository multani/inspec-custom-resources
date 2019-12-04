class NomadCluster < Inspec.resource(1)
  name 'nomad_cluster'
  desc 'Test the configuration of a Nomad cluster'
  example "
    describe nomad_cluster('http://localhost:4646') do
      it { should be_reachable }
      it { should have_leader }
      its('servers_count'){ should be >= 3 }
      its('nodes_count'){ should eq 2 }
    end
  "

  def initialize(url)
    @url = url

    query = inspec.http(url)
    begin
      status = query.status()
    rescue => e # something wrong happened while checking the HTTP status
      fail_resource("Nomad cluster unreachable: #{e}")
    end
  end

  def has_leader?
    http_json("#{@url}/v1/status/leader") != ''
  end

  def servers_count
    members = http_json("#{@url}/v1/agent/members")

    servers = 0
    members["Members"].each do |member|
      servers += 1 unless member['Tags']['role'] != 'nomad' or member['Status'] != 'alive'
    end
    servers
  end

  def nodes
    nodes = http_json("#{@url}/v1/nodes")
    nodes.map { |node| inspec.nomad_node(@url, node['ID']) }
  end

  def nodes_count
    nodes = http_json("#{@url}/v1/nodes")

    available_nodes = 0
    nodes.each do |node|
      available_nodes += 1 unless node['Status'] != 'ready'
    end
    available_nodes
  end

  def to_s
    "Nomad at #{@url}"
  end

  def method_missing(name)
    @params[name.to_s]
  end

  private

  def http_json(url)
    query = inspec.http(url)
    if query.status != 200
      raise Inspec::Exceptions::ResourceFailed, "Nomad query on #{url} return HTTP code #{query.status}"
    end

    begin
      require 'json'
      JSON.parse(query.body)
    rescue => e
      raise Inspec::Exceptions::ResourceFailed, "Unable to parse JSON from Nomad query on #{url}: #{e.message}"
    end
  end
end
