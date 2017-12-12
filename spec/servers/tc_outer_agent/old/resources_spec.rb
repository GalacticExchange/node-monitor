require 'spec_helper'

opt = $server_config

##

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