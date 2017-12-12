require 'spec_helper'

opt = $server_config
dc = "docker exec gex-api"

# nodejs version
describe command("#{dc} node -v") do
  it "version" do
    expect(subject.stdout).to match(/v6\./)
  end
end

describe command("#{dc} npm -v") do
  it "version" do
    expect(subject.stdout).to match(/^3\./)
  end
end


