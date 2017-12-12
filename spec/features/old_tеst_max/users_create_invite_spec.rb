RSpec.describe "Create user by invitation", :type => :request do


  describe 'create user by invite to team' do
    before :each do
      TestEmailRedis::Helpers.clean_emails_all

      #
      @admin_hash = build_user_hash
      api_create_user_verified @admin_hash

      # auth as admin
      @auth_token = api_auth(@admin_hash[:username], @admin_hash[:password])

      #
      @user_hash = build_user_hash

      #
      TestEmailRedis::Helpers.clean_emails_all

    end

    it 'create user in team' do
      # send invite
      api_do_request :post, 'userInvitations', {"email" => @user_hash[:email]}, {"token" => @auth_token}

      # get invitation link from email
      mail = TestEmailRedis::Helpers.get_last_email_for_user @user_hash[:email]
      link = invitation_get_accept_link_from_email(mail)

      #
      expect(link).not_to be be_nil
      expect(link.length).to be > 1

      # visit link in browser
      visit link

      expect(page).to have_css 'form#new_user'

      # fill form
      f = find('form#new_user')
      f.fill_in 'user_username', :with => @user_hash[:username]
      f.fill_in 'user_firstname', :with => @user_hash[:firstname]
      f.fill_in 'user_lastname', :with => @user_hash[:lastname]
      f.fill_in 'user_password', :with => @user_hash[:password]
      f.fill_in 'user_password_confirmation', :with => @user_hash[:password]

      f.find('input[type=submit]').click

      #
      expect(current_path).to match /users\/created/


      # check user can login to api
      @user_auth_token = api_auth(@user_hash[:username], @user_hash[:password])

      expect(@user_auth_token.length).to be > 0
    end

  end


  describe 'create user by invite to SHARE' do
    before :each do
      #
      TestEmailRedis::Helpers.clean_emails_all

      #
      @admin_hash = build_user_hash
      api_create_user_verified @admin_hash

      # auth as admin
      @auth_token = api_auth(@admin_hash[:username], @admin_hash[:password])

      #
      @user_hash = build_user_hash

      # delete first 2 emails
      TestEmailRedis::Helpers.wait_for_new_email_for_user @admin_hash[:email], {n_old_emails: 1}
      TestEmailRedis::Helpers.clean_emails_for_user @admin_hash[:email]

    end

    after :each do
      TestEmailRedis::Helpers.clean_emails_all
    end

    it 'create user and create share' do
      # send invite to share
      api_do_request :post, 'shareInvitations', {"email" => @user_hash[:email]}, {"token" => @auth_token}

      # get invitation link from email
      mail = TestEmailRedis::Helpers.get_last_email_for_user @user_hash[:email]

      link = invitation_get_accept_link_from_email(mail)

      #
      expect(link).not_to be be_nil
      expect(link.length).to be > 1

      # visit link in browser
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
      expect(current_path).to match /users\/created/


      # check user can login to api
      @user_auth_token = api_auth(@user_hash[:username], @user_hash[:password])

      expect(@user_auth_token.length).to be > 0
    end

  end
end

