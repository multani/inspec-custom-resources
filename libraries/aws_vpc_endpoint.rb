class AWSVpcEndpoint < Inspec.resource(1)
  name 'aws_vpc_endpoint'
  desc 'Test the configuration of a VPC endpoint. https://github.com/inspec/inspec-aws/issues/21'
  example "
    describe aws_vpc_endpoint('vpce-1234') do
      it { should exist }
      its('state') { should eq 'available' }
      its('vpc_id') { should eq 'vpc-00000' }
      its('endpoint_type') { should eq 'Interface' }
      its('service_name') { should eq 'com.amazonaws.ap-southeast-2.s3' }
      its('route_tables') { should include 'rtb-00000' }
    end
  "

  def initialize(vpc_endpoint_id)
    @vpc_endpoint_id = vpc_endpoint_id
    @vpc_endpoint = get_vpc_endpoint(vpc_endpoint_id)
  end

  def to_s
    "VPC Endpoint #{@vpc_endpoint_id}"
  end

  def exists?
    @vpc_endpoint != nil
  end

  def state
    @vpc_endpoint.state
  end

  def vpc_id
    @vpc_endpoint.vpc_id
  end

  def endpoint_type
    @vpc_endpoint.vpc_endpoint_type
  end

  def service_name
    @vpc_endpoint.service_name
  end

  def route_tables
    @vpc_endpoint.route_table_ids
  end

  private

  def get_vpc_endpoint(vpc_endpoint_id)
    ec2 = Aws::EC2::Client.new
    vpc_endpoints = ec2.describe_vpc_endpoints(vpc_endpoint_ids: [vpc_endpoint_id]).vpc_endpoints
    vpc_endpoints[0]
  end
end
