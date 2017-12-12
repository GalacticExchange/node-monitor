require 'spec_helper'

opt = $server_config
dc = "docker exec gex-api"
SIDE_ENV = $gex_env == 'prod' ? "production" : "main"
##
describe 'God check' do
  di_process_is_running("gex-api", "god")
  di_process_is_running("gex-api", "sidekiq")

  describe command("#{dc} ps -ef | grep god") do
    it "response" do
      expect(subject.stdout).to match(/-l *\/var\/log\/god\/god\.log/im)
      #expect(subject.stdout).to match(/-P *\/var\/run\/god\.pid/im)     #ash ?????????????????
      expect(subject.stdout).to match(/-c \/opt\/god\/master\.conf/im)
    end
  end


  # describe command("#{dc} ls /var/run/") do
  #   it "response" do
  #     expect(subject.stdout).to match(/god\.pid/im)
  #   end
  # end

  # describe file('/var/run/god.pid') do
  #   it { should be_file }
  # end

  describe command("#{dc} /opt/god/god status") do
    it "response" do
      expect(subject.stdout).to match(/apihub-sidekiq-#{SIDE_ENV}-all_nolog-0: up/im)
    end
  end

  describe command("#{dc} pgrep -f sidekiq") do
    it "response" do
      expect(subject.stdout).to match(/^\d+$\n^\d+$/im)
    end
  end

  describe command("#{dc} cat /opt/god/master.conf") do
    it "response" do
      expect(subject.stdout).to match(/^\load\ \"\/var\/www\/apps\/apihub\/current\/config\/god\/sidekiq\.#{SIDE_ENV}\.rb\"/im)
    end
  end

  # describe file('/opt/god/master.conf') do
  #   it { should contain %Q(load "/var/www/apps/apihub/current/config/god/sidekiq.#{$gex_env}.rb") }
  # end

end
