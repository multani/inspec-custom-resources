class NomadJob < Inspec.resource(1)
  name 'nomad_job'
  desc 'Test a specific Nomad job on a Nomad cluster'
  example "
    describe nomad_job('http://localhost:4646', 'test_job') do
      it { should be_running }
    end
  "

  def initialize(url, job_name)
    @url = url
    @job_name = job_name

    query = inspec.http(url)
    begin
      status = query.status()
    rescue => e # something wrong happened while checking the HTTP status
      fail_resource("Nomad cluster unreachable: #{e}")
    end
  end

  def running?
    job = http_json("#{@url}/v1/job/#{@job_name}")
    job['Status'] == 'running'
  end

  def to_s
    "Nomad job #{@job_name} at #{@url}"
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
