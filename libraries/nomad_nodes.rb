class NomadNodes < Inspec.resource(1)
  name 'nomad_nodes'
  desc 'Verifier for a set of Nomad nodes'
  example "
    # Describe a *set* of Nomad nodes
    describe nomad_nodes('http://localhost:4646') do
      # One of the matching node should have the specific node class
      its('node_class') { should include 'test1' }
      its('status') { should include 'ready' }
      its('count') { should eq 5 }
    end

    describe nomad_nodes('http://localhost:4646').where(
      NodeClass: 'foobar'
    ) do
      its('status') { should include 'ready' }
      its('count') { should eq 1 }
    end
  "

  def initialize(cluster_url, token=nil)
    @cluster_url = cluster_url
    @token = if token != nil then token else ENV.fetch('NOMAD_TOKEN', nil) end
  end

  # https://github.com/inspec/inspec/blob/master/docs/dev/filtertable-usage.md
  filter = FilterTable.create
      .register_column(:node_class, field: "NodeClass")
      .register_column(:status,     field: "Status")
      .install_filter_methods_on_resource(self, :filter_nodes)

  def to_s
    "Nomad Nodes on #{@cluster_url}"
  end

  private

  def filter_nodes
    nodes = http_json("#{@cluster_url}/v1/nodes")
    nodes.map { |n| http_json("#{@cluster_url}/v1/node/#{n['ID']}") }
  end

  def http_json(url)
    headers = {
      'x-nomad-token': @token
    }
    query = inspec.http(url, headers=headers)
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
