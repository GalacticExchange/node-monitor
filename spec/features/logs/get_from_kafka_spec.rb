RSpec.describe "kafka", :type => :request do

  describe "kafka get/post" do
    before :all do
    end

    it 'debug' do
      #raise 'just debug - not work in real'

      $logger.offset = 514366
      event = wait_log_event("node_installed", 60, {cluster_id: 196})

      expect(event).not_to be_nil

      puts "event: #{event}"

    end

    it 'debug 2' do
      #raise 'just debug - not work in real'

      $logger.offset = 600000
      #event = wait_log_event("node_status_changed", 600, {cluster_id: 196})
      event = wait_log_event("node_status_changed", 600, {})

      expect(event).not_to be_nil

      puts "event: #{event}"

    end

    it "get custom message from kafka" do
      #@msg_type = random_string(20)
      @msg_type = "debug_#{random_string(4)}"
      @msg = "something"


      # post to kafka
      resp = api_do_request :get, 'debug/log_to_kafka', {msg_type: @msg_type, delay: 5}, {}

      expect(resp.code).to eq 200
      resp_data = JSON.parse(resp.body)


      # work
      event = wait_log_event(@msg_type, 60)

      #
      expect(event).not_to be_nil

      puts "event: #{event}"

    end

    it 'async event' do
      # do async task
      resp = api_do_request :get, 'debug/task_async', {delay: 5}, {}

      expect(resp.code).to eq 200
      resp_data = JSON.parse(resp.body)


      # work
      event = wait_log_event('debug_long_started', 300)
      expect(event).not_to be_nil
      puts "event: #{event}"
    end

    it "log offset" do
      @msg_type = "debug1_#{random_string(4)}"


      # post to kafka
      resp = api_do_request :get, 'debug/log_to_kafka', {msg_type: @msg_type, delay: 3}, {}

      # just wait - more logs will be added meanwhile
      sleep 5

      # work
      msg1 = wait_log_event(@msg_type, 10)

      # event2
      msg_type2 = "debug2_#{random_string(4)}"
      resp = api_do_request :get, 'debug/log_to_kafka', {msg_type: msg_type2, delay: 20}, {}

      # add some logs to kafka
      resp = api_do_request :get, 'ping', {}, {}
      resp = api_do_request :get, 'ping', {p1: "1"}, {}

      # just wait - more logs will be added meanwhile
      sleep 10

      # another dummy log
      resp = api_do_request :get, 'debug/log_to_kafka', {msg_type: 'delmenow1', delay: 20}, {}


      # work
      event2 = wait_log_event(msg_type2, 60)

      #
      expect(event2).not_to be_nil

      puts "event: #{event2}"

    end

    it 'log with filter' do
      #
      resp = api_do_request :get, 'ping', {}, {}

      #
      event = wait_log_event('api_request_start', 60, {ip: '127.0.0.1'})

      #
      expect(event).not_to be_nil

      puts "event: #{event}"

    end


  end
end
