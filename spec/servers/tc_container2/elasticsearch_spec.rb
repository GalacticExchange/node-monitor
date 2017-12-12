require 'spec_helper'

opt = $server_config

# es connect
describe command("curl -X GET http://51.0.0.13:9200") do
  it "response" do
    expect(subject.stdout).to match(/"cluster_name" : "elasticsearch"/im)
  end
end


