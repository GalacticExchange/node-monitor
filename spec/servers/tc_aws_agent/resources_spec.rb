require 'spec_helper'

opt = $server_config

##


# describe command("hostname") do
#   it "debug hostname" do
#     puts "HOSTNAME = #{subject.stdout}"
#     expect(subject.stdout).to match(/agent/)
#   end
# end
#
# describe command("ping -c 1 -w 1 104.247.203.210") do
#   it "ping gex4 hostname" do
#     puts "ping result = #{subject.stdout}"
#     expect(subject.stdout).to match(/0% packet loss/)
#   end
# end
#
#
# describe command("nmap 104.247.203.210 -p 8111 -sV --version-all -oG - | grep -iq '8111/open'") do
#   it "teamcity on gex4 - port 8111" do
#     puts "nc result = #{subject.stdout}"
#     expect(subject.exit_status).to eq(0)
#   end
# end



#
# describe "free memory > 100 mB" do
#   it "check" do
#     freemem = host_inventory['memory']['free'].delete("kB").to_i
#     puts "free memory: #{freemem}"
#     expect(freemem).to be > 102400
#   end
# end

describe "Free memory > 500 mB" do
  it "check" do
    free_mem = host_inventory['memory']['free'].delete("kB").to_i
    buffers_mem = host_inventory['memory']['buffers'].delete("kB").to_i
    cached_mem = host_inventory['memory']['cached'].delete("kB").to_i
    totalfree_mem = free_mem + buffers_mem + cached_mem
    puts "free memory: #{free_mem}"
    puts "buffers memory: #{buffers_mem}"
    puts "cached memory: #{cached_mem}"
    puts "total free memory: #{totalfree_mem}"

    expect(totalfree_mem).to be > 512000
  end
end