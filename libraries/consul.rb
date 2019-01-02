require 'diplomat'

class ConsulCluster < Inspec.resource(1)
  name 'consul_cluster'
  desc 'Test the configuration of a Consul cluster'
  example "
    describe consul_cluster('http://localhost:8500') do
      it { should be_reachable }
      it { should have_leader }
      its('servers_count'){ should be >= 3 }
      its('datacenter'){ should include 'dc1' }
    end
  "

  def initialize(url)
    @url = url
    Diplomat.configure do |config|
      config.url = @url
      #config.acl_token =  "xxxxxxxx-yyyy-zzzz-1111-222222222222"
    end
  end

  def reachable?
    begin
      Diplomat::Status.leader()
    rescue Faraday::ConnectionFailed
      return false
    rescue
    end

    true
  end

  def has_leader?
    begin
      Diplomat::Status.leader() != ""
    rescue
      false
    end
  end

  def servers_count
    servers = []
    begin
      Diplomat::Agent.members().each do |member|
        servers << member unless member['Tags']['role'] != 'consul' or member['Status'] != 1
      end
      servers.count
    rescue
      0
    end
  end

  def datacenter
    begin
      Diplomat::Datacenter.get
    rescue
      []
    end
  end

  def to_s
    "Consul(#{@url})"
  end

  def method_missing(name)
    @params[name.to_s]
  end
end
