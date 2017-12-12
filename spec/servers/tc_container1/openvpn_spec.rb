require 'spec_helper'

opt = $server_config

##
HOSTNAME = "openvpn"
describe command("docker exec #{HOSTNAME} dig @51.0.1.8 openvpn") do
  it "dig @51.0.1.8 openvpn" do
    stdoutput = subject.stdout.gsub /^.*ANSWER SECTION:/im, ''
    stdoutput = subject.stdout
    puts stdoutput
    expect(stdoutput).to match(/51\.0\.1\.8/)
  end
end

di_process_running(HOSTNAME, "dnsmasq")