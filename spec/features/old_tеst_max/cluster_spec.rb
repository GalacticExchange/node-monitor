RSpec.describe "Cluster", :type => :request do

  describe 'master' do

    before :each do
      # requirements
      # * cluster should be installed
      # * gexd should be installed on client machine

      @client_config = get_client_config(ENV['client'])

      @username = ENV['username']
      @password = ENV['user_pwd']

    end


    it 'debug' do

    end
  end
end
