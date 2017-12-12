require "fog"

class AwsHelper

  def self.fog(region, config)
    fog = Fog::Compute.new(
        :provider => 'AWS',
        :region => region,
        :aws_access_key_id => config['key_id'],
        :aws_secret_access_key => config['secret_key']
    )

    fog
  end


  def self.find_vpc_by_cluster_uid(fog, cluster_uid)
    # vpc is created
    a_vpc = fog.describe_vpcs.body['vpcSet']

    vpc = nil
    a_vpc.each do |r|
      if r['tagSet']['cluster_uid'] == cluster_uid
        vpc = r
        break
      end
    end

    vpc
  end

  def self.find_instance_by_cluster_uid(fog, cluster_uid)
    a_instances = fog.describe_instances.body['reservationSet']

    instance = nil
    a_instances.each do |rr|
      r = rr['instancesSet'][0]

      next if r['instanceState']['name']=='terminated'

      if r['tagSet']['cluster_uid'] == cluster_uid
        instance = r
        break
      end
    end

    instance
  end

end
