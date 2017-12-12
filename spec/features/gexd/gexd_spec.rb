RSpec.describe "Gexd program", :type => :request do

  describe 'install' do

    before :each do
      # requirements
      # * cluster should be installed
      # * gexd should be installed on client machine

      @client_config = get_client_config(ENV['client'])

      @username = ENV['username']
      @password = ENV['user_pwd']

      #
      gexd_remove_all(@client_config)
    end


    it 'install gexd' do
      res = update_gex(@client_config)

      puts "res: #{res.inspect}"

    end

    it 'update gexd' do
      res = update_gex(@client_config)

      puts "res: #{res.inspect}"
    end
  end
end

