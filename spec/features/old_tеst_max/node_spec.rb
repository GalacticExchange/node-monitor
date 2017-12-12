RSpec.describe "Node", :type => :request do
  # requirements
  # * cluster should be installed
  # * gexd should be installed on client machine


  describe 'state' do

    before :each do

      @client_config = get_client_config(ENV['client'])

      @username = ENV['username']
      @password = ENV['user_pwd']

    end


    it 'debug' do

    end
  end
end
