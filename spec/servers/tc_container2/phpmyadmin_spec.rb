require 'spec_helper'

opt = $server_config

# can connect to mysql (ping)
di_ping("gex-phpmyadmin", "mysql")
