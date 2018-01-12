require 'rake'
require 'rspec/core/rake_task'
require 'json'

require_relative 'spec/support/helpers/servers_helpers'
require_relative 'spec/support/helpers/gexcloud_helpers'




# load global data

# servers
#hosts = JSON.parse(File.read('data/servers/servers.json'))

# env
$gex_env = ENV['gex_env'] || 'main'

# all servers
$servers = ServersHelpers.get_servers_config

# servers info
$hostname = ENV['HOSTNAME'] || ENV['server']
$server_config = ServersHelpers.load_server_config $hostname

puts "Rakefile: hostname=#{$hostname}, config: #{$server_config}"



#namespace :serverspec do
#  task :all => hosts.keys.map{|r| r.to_sym}
#end


###

#desc "Run serverspec to all hosts"
task :default => 'serverspec:all'

=begin
task :spec    => 'spec:all'
task :default => :spec

namespace :spec do
  targets = []
  Dir.glob('./spec/*').each do |dir|
    next unless File.directory?(dir)
    target = File.basename(dir)
    target = "_#{target}" if target == "default"
    targets << target
  end

  task :all     => targets
  task :default => :all

  targets.each do |target|
    original_target = target == "_default" ? target[1..-1] : target
    desc "Run serverspec tests to #{original_target}"
    RSpec::Core::RakeTask.new(target.to_sym) do |t|
      ENV['TARGET_HOST'] = original_target
      t.pattern = "spec/#{original_target}/*_spec.rb"
    end
  end
end

=end

=begin
namespace :debug do
  task :debug do
    puts "1"

    hosts.each do |host, props|
      # find spec files
      Dir.glob("spec/servers/#{host}/*_spec.rb") do |spec_file|
        spec_name = spec_file[/\/([a-z_]+)_spec\.rb/, 1]

        puts "#{spec_name}"


      end
    end

  end

end
=end


namespace :serverspec do

  #task :all => hosts.keys.map{|r| r.to_sym}

  #hosts.each do |host, props|
    # find spec files
    #Dir.glob("spec/servers/#{host}/*_spec.rb") do |spec_file|

  Dir.glob("spec/servers/*/") do |spec_dir|

    hostname = spec_dir[/\/([a-z\d_]+)\/([a-z\d_]+)/, 2]

    desc "Run serverspec to #{hostname}, ALL tasks"
    RSpec::Core::RakeTask.new(:"#{hostname}") do |t|
      props = $servers[hostname]
      ENV['test_type'] = 'serverspec'
      ENV['HOSTNAME'] = hostname
      #ENV['TARGET_HOST'] = props['ip'] || props['host']
      ENV['TARGET_HOST'] = props['host']
      ENV['TARGET_HOST_TYPE'] = props['type']
      ENV['SSH_USER'] = props['user']
      ENV['SSH_PASSWORD'] = props['password']
      #
      t.pattern = "spec/servers/#{hostname}/*_spec.rb"
    end
  end

  Dir.glob("spec/servers/*/*_spec.rb") do |spec_file|

    hostname = spec_file[/\/([a-z\d_]+)\/([a-z_]+)_spec\.rb/, 1]
    spec_name = spec_file[/\/([a-z\d_]+)\/([a-z_]+)_spec\.rb/, 2]

    desc "Run serverspec to #{hostname}, task #{spec_name}"
    RSpec::Core::RakeTask.new(:"#{hostname}_#{spec_name}") do |t|
      props = $servers[hostname]
      #props = $server_config
      #
      ENV['test_type'] = 'serverspec'
      ENV['HOSTNAME'] = hostname
      #ENV['TARGET_HOST'] = props['ip'] || props['host']
      ENV['TARGET_HOST'] = props['host']
      ENV['TARGET_HOST_TYPE'] = props['type']
      ENV['SSH_USER'] = props['user']
      ENV['SSH_PASSWORD'] = props['password']

      puts "props=#{props.inspect}"

      #
      t.rspec_opts = %w[-f JUnit -o rspec.xml]

      t.pattern = "spec/servers/#{hostname}/#{spec_name}_spec.rb"
      #t.pattern = "spec/servers/{base,#{host}}/*_spec.rb"

      #target_run_list = host_run_list[target_host]
      #recipes = Chef::RunList.new(*target_run_list).expand("_default", "disk").recipes
      #t.pattern = ['../chef/site-cookbooks/{' + recipes.join(',') + '}/spec/*_spec.rb', "spec/#{target_host}/*_spec.rb"]
    end
  end

end
