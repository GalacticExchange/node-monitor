require 'spec_helper'

opt = $server_config

describe "debug" do
  it "debug" do
    sbj= command('hostname')
    stdoutput = sbj.stdout
    puts stdoutput
  end
end

describe 'phpMyAdmin by port 8081' do
  describe host('46.172.71.54') do
    # ping
    it { should be_reachable }
    it { should_not be_reachable.with( :port => 8081 ) }

  end
end


# port 8081 open to public

# security for port 8081
  #only from our office


# can connect to mysql
