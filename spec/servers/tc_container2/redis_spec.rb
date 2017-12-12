require 'spec_helper'

opt = $server_config

# redis
REDIS_IP =  '51.0.0.12'
describe command("redis-cli -h #{REDIS_IP } ping") do
  it "ping" do
    expect(subject.stdout).to match(/PONG/)
  end
end




