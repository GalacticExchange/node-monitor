#require 'rubygems'

test_type = ENV['test_type']

if test_type=='serverspec'
  require 'serverspec_helper'
else
  require 'base_spec_helper'
end
