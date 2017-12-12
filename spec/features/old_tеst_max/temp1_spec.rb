RSpec.describe "Mytest", :type => :request do

  describe "visit" do
    it "should be eq" do
      expect(3).to   eq(3)
    end

    it "open home page" do
      visit '/'

      #within("#session") do
      #  fill_in 'Email', :with => 'user@example.com'
      #  fill_in 'Password', :with => 'password'
      #end
      #click_button 'Sign in'

      expect(page).to have_content 'You need to sign in or sign up'
    end

    it 'debug' do
      @user_hash = build_user_hash
      @user_hash[:email] = 'claire.feest@hackettmacejkovic.name'

      link = 'http://localhost:3000/users/new?invitationToken=4153229072585'

      visit link

      expect(page).to have_css 'form#new_user'

      # fill form
      f = find('form#new_user')
      f.fill_in 'user_team_name', :with => @user_hash[:teamname]
      f.fill_in 'user_username', :with => @user_hash[:username]
      f.fill_in 'user_firstname', :with => @user_hash[:firstname]
      f.fill_in 'user_lastname', :with => @user_hash[:lastname]
      f.fill_in 'user_password', :with => @user_hash[:password]
      f.fill_in 'user_password_confirmation', :with => @user_hash[:password]

      f.find('input[type=submit]').click

      #
      expect(current_path).to match /users_result_created/


      # check user can login to api
      @user_auth_token = api_auth(@user_hash[:username], @user_hash[:password])

      expect(@user_auth_token.length).to be > 0

    end

  end


end
