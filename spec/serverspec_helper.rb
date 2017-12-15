require 'serverspec'
require 'docker'
require 'net/ssh'
require 'json'
require_relative 'support/helpers/servers_helpers'
require_relative 'support/helpers/gexcloud_helpers'
require_relative 'support/helpers/docker_helpers'

#
current_dir = File.dirname(__FILE__)

# config
#$gex_env ||= ENV['gex_env']
$gex_env ||= 'main'

#
$hostname = ENV['HOSTNAME'] || ENV['server']


# gexcloud servers
$gexcloud_servers = GexcloudHelpers.get_servers_config

# server info
$server_config = ServersHelpers.load_server_config $hostname

puts "server name = #{$hostname}, gex_env = #{$gex_env}"
#puts "server name = #{$hostname}, type=#{ENV['TARGET_HOST_TYPE']}, gex_env = #{$gex_env}"
puts "server config: #{$server_config}"
#exit

if $server_config['host'].nil? || $server_config['host']==''
  raise 'Server host not set'
  exit
end






############## BACKEND

## SSH

#puts "type==#{ENV['TARGET_HOST_TYPE']}"

if ENV['TARGET_HOST_TYPE']=='ssh'
  set :backend, :ssh

  if ENV['ASK_SUDO_PASSWORD']
    begin
      require 'highline/import'
    rescue LoadError
      fail "highline is not available. Try installing it."
    end
    set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
  else
    set :sudo_password, ENV['SUDO_PASSWORD']
  end

  set :sudo_password, ENV['SSH_PASSWORD']

  #
  #host = ENV['TARGET_HOST']
  host = $server_config['ip'] || $server_config['host']

  #set :host,        options[:host_name] || host
  set :host,        host

  #
  options = Net::SSH::Config.for(host)

  options[:user] ||= Etc.getlogin
  #options[:user] = ENV['SSH_USER']
  #options[:password] = ENV['SSH_PASSWORD']
  options[:user] = $server_config['user']
  options[:password] = $server_config['password']
  options[:port] = $server_config['port'] || 22


  set :ssh_options, options

# Disable sudo
# set :disable_sudo, true


# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C'

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'

  #puts "!!! TARGET - ssh !!!!"
elsif ENV['TARGET_HOST_TYPE']=='local'
  set :backend, :exec
  #puts "!!! TARGET - local !!!!"

elsif ENV['TARGET_HOST_TYPE']=='docker'
  set :backend, :exec
end



RSpec.configure do |config|
  include DockerHelpers
end