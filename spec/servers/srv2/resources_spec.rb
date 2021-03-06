require 'spec_helper'

opt = $server_config
puts "opt = #{opt}"

ProcessesNumberMax = 200

##

if $gex_env == 'prod'
  puts 'testing free disk space on PROD...'
  describe "free disk space > 3 gB" do
    it "check" do
      freespace = host_inventory['filesystem']['/dev/mapper/gex2--vg-root']['kb_available'].delete("kB").to_i
      puts "free disk spase: #{freespace}"
      expect(freespace).to be > 3072000
    end
  end
else
  puts 'testing free disk space on MAIN...'
  describe "free disk space > 3 gB" do
    it "check" do
      freespace = host_inventory['filesystem']['/dev/sdb1']['kb_available'].delete("kB").to_i
      puts "free disk spase: #{freespace}"
      expect(freespace).to be > 3072000
    end
  end
end

describe "free memory > 100 mB" do
  it "check" do
    freemem = host_inventory['memory']['free'].delete("kB").to_i
    puts "free memory: #{freemem}"
    expect(freemem).to be > 102400
  end
end

describe "free memory > 500 mB" do
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

describe command("pgrep socat|wc") do
  it "socats number" do
    stdoutput = subject.stdout.lstrip.split(/\s/).first.to_i
    puts " #{stdoutput}"
    expect(stdoutput).to be <ProcessesNumberMax
  end
end

describe command("pgrep openvpn|wc") do
  it "socats number" do
    stdoutput = subject.stdout.lstrip.split(/\s/).first.to_i
    puts " #{stdoutput}"
    expect(stdoutput).to be <ProcessesNumberMax
  end
end

describe command("pgrep consul|wc") do
  it "socats number" do
    stdoutput = subject.stdout.lstrip.split(/\s/).first.to_i
    puts " #{stdoutput}"
    expect(stdoutput).to be <ProcessesNumberMax
  end
end

describe command("pgrep zookeeper|wc") do
  it "socats number" do
    stdoutput = subject.stdout.lstrip.split(/\s/).first.to_i
    puts " #{stdoutput}"
    expect(stdoutput).to be ==0
  end
end
