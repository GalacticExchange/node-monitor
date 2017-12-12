$redis = Redis.new(:host => Myconfig.config[:redis_host], :port => 6379)

$test_config = Myconfig.config

#File.join(File.dirname(__FILE__), "..", '..')
$root_dir = File.dirname(File.expand_path('../', File.dirname(__FILE__)))

#raise "root=#{$root_dir}"

# mail
TestEmailRedis.set_config({
  redis_prefix: Myconfig.config[:redis_prefix],
  field_user_id: :in_reply_to
})


# ssh
require 'sshkit'
require 'sshkit/dsl'
include SSHKit::DSL
require 'sshkit/sudo'


#SSHKit::Backend::Netssh.pool.idle_timeout = 6000
SSHKit::Backend::Netssh.pool.idle_timeout = 0


# logger
require_relative 'helpers/app_logger'

puts " kafka: skip all"
$logger = AppLogger.new
$logger.offset = 0
$logger.log_skip_all


