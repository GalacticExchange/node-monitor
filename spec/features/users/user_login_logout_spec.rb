RSpec.describe "Login user ", :type => :request do


  #use_headless

  describe "login" do





    after(:each) do |example|
      sign_out

      # if example.exception != nil
      #   passed = false
      #   ex = example.exception.to_s
      # else
      #   passed = true
      #   ex = ''
      # end



      # SlackHelper.test_send({
      #   passed: passed,
      #   event: 'cluster_created',
      #   data: <<-EOF
      #     Info:
      #     Cluster name: 'test-cluster'
      #     Cluster id: 123
      #     Ex: #{ex}
      #   EOF
      # })

    end

    # unless Gem.win_platform?
    #   headless = Headless.new(dimensions: "1600x900x24", display: 99, autopick: true, reuse: false, destroy_at_exit: true).start
    # end


    it 'user login'  do


      # user login
      fill_in 'user_login', :with => "kennedi-abernathy"
      fill_in 'user_password', :with => 'Password1'
      login_button.click

      create_cluster_button.click
      title = find('[data-div="page-title"]')
      title.find('h2').text.should == 'Create cluster'
      title.find('p').text.should == 'Step 1: Choose the type.'




    end

  end


end