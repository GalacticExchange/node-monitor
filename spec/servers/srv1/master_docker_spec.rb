require 'spec_helper'

opt = $server_config

# IP

describe command("sudo docker ps") do
  it "docker ps" do
    stdoutput = subject.stdout
    puts " #{stdoutput}"
    expect(stdoutput).to match(/hadoop-/)
  end
end