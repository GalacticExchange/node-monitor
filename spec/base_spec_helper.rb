require 'rubygems'
require 'redis'
require 'httparty'
#require "rack/test"
require 'faker'
require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'open3'
require 'date'
require 'time'
require 'fog/aws'
require 'headless'
require "chromedriver-screenshot"
require "slack-ruby-client"


Slack.configure do |config|
  config.token = 'xoxb-133313763122-OD2x8uk9A2UwjJ7SfTFmepzF'
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

ChromedriverScreenshot.take_full_screenshots = true

# env
$env = ENV['RAILS_ENV'] || ENV['gex_env'] || 'development'

puts "ENV=#{$env}"
Dir[File.join(File.dirname(__FILE__), "..", "config", 'environments', "#{$env}.rb")].each do |f|
  require f
end

#
require 'test_email_redis'
require 'test_email_redis/helpers'
if ENV['browser'] == 'chrome'
  # for testing features in browser
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome, args: ["--window-size=2400,1600"])
  end

  Capybara.javascript_driver = :chrome

  Capybara.configure do |config|
    config.default_max_wait_time = 20 # seconds
    config.default_driver = :selenium
  end
else
  Capybara.register_driver :selenium do |app|
    caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"binary" => '/usr/lib/gex/ui/ClusterGX'})
    $driver = Capybara::Selenium::Driver.new(app, {:browser => :chrome, :desired_capabilities => caps, driver_path: './chromedriver/chromedriver-lnx'})
  end
end
Capybara.configure do |config|
  config.default_driver = :selenium
  config.javascript_driver = :selenium
end

Capybara.run_server = false
# Capybara.current_driver = :selenium
Capybara.app_host = Myconfig::HUB_HOST
Capybara.default_max_wait_time = 15
#Capybara.server_port = 3000
Capybara.default_selector = :css
# Capybara.javascript_driver = :selenium


# init
require File.join(File.dirname(__FILE__), "..", "spec", 'support', 'init.rb')

#
Dir[File.join(File.dirname(__FILE__), "..", "spec", 'support', 'helpers', "**.rb")].each do |f|
  require f
end


#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true

    expectations.syntax = [:should, :expect]
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end

  # rspec
  include Rack::Test::Methods

  # capybara
  include Capybara::DSL

  # my helpers
  include RequestHelpers
  include SshHelpers
  include GexdHelpers

  include ApiHelpers
  include ApiAuthHelpers
  include ApiUserFactoryHelpers

  include ResetpwdHelpers
  include NodeHelpers

  include InvitationHelpers

  include KafkaHelpers

  include Element
  include UITestHelper
  include HeadlessHelpers
  include HelperApi
  include SlackHelper
  include SlackMsgHelper

end

