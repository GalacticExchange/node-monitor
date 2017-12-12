RSpec.describe "Reset password", :type => :request do

  describe 'user reset password' do

    before :each do
      #
      TestEmailRedis::Helpers.clean_emails_all

      # create user
      @user_hash_post = build_user_hash_post
      api_create_user_verified @user_hash_post

      @username = @user_hash_post[:username]
      @email = @user_hash_post[:email]


      # skip 2 emails
      TestEmailRedis::Helpers.wait_for_new_email_for_user @email, {n_old_emails: 1}
      TestEmailRedis::Helpers.clean_emails_for_user @email

      #@n_old_emails = TestEmailRedis::Helpers.n_emails_for_user @email


    end

    it 'email to send link' do
      # send link
      api_do_request :post, '/users/password/resetlink', {username: @user_hash_post[:email]}, {}

      # check token in email
      #mail = TestEmailRedis::Helpers.get_last_email_for_user @email, true, {n_old_emails: @n_old_emails}
      mail = TestEmailRedis::Helpers.get_last_email_for_user @email

      token = mail_get_resetpwd_token_from_email(mail)
      link = get_resetpwd_link_from_email(mail)

      #
      expect(token.length).to be > 1

      expect(link).not_to be be_nil
      expect(link.length).to be > 1

    end


    it 'change password from link' do
      # send link
      api_do_request :post, '/users/password/resetlink', {username: @user_hash_post[:username]}, {}

      # check token in email
      #mail = TestEmailRedis::Helpers.get_last_email_for_user @email, true, {n_old_emails: @n_old_emails}
      mail = TestEmailRedis::Helpers.get_last_email_for_user @email

      token = mail_get_resetpwd_token_from_email(mail)
      link = get_resetpwd_link_from_email(mail)

      #
      expect(token.length).to be > 1

      # edit password
      expect(link).not_to be be_nil
      expect(link.length).to be > 1

      # open form
      visit link

      expect(page).to have_css 'form#new_user'

      oldpwd = @user_hash_post[:password]
      newpwd = Faker::Internet.password(8)

      # fill form
      f = find('form#new_user')
      f.fill_in 'user_password', :with => newpwd
      f.fill_in 'user_password_confirmation', :with => newpwd

      f.find('input[type=submit]').click

      #
      #expect(current_path).to match /users\/passwordchanged/
      expect(current_path).to match /login/


      # check new pwd
      # cannot login with old pwd
      token = api_auth(@username, oldpwd)
      expect(token).to be nil

      # can login with new pwd
      token = api_auth(@username, newpwd)
      expect(token.length).to be > 1


    end



  end
end

