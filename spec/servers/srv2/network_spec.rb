require 'spec_helper'

opt = $server_config

describe command("pgrep apac") do
  it "pgrep apac" do
    stdoutput = subject.stdout
    puts " #{stdoutput}"
    expect(stdoutput).to eq('')
  end
end
##
=begin
describe command("ip route") do
  it "ip route default" do
    expect(subject.stdout).to match(/default\s+via\ #{opt['gateway']}/)
  end
  it "ip route 51.x" do
    expect(subject.stdout).to match(/51.0.0.0\/9 dev eth1/)
  end

end
=end

=begin
default via 51.0.0.1 dev eth1
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
10.0.3.0/24 dev lxcbr0  proto kernel  scope link  src 10.0.3.1
51.0.0.0/8 dev eth1  proto kernel  scope link  src 51.0.1.21

=end
