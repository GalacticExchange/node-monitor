RSpec.describe "Create user", :type => :request do

  describe "create not verified" do
    before :each do
      TestEmailRedis::Helpers.clean_emails_all
    end

    it "create user with API" do
      user_hash_post = build_user_hash_post

      resp = api_do_request :post, 'users', user_hash_post, {}
      resp_data = JSON.parse(resp.body)

      # email
      mail = TestEmailRedis::Helpers.get_last_email_for_user user_hash_post[:email]

      # token in email
      verification_token = api_mail_get_verification_token_from_email(mail)

      expect(verification_token.to_s.length).to be  > 0

    end

    it "create user with site" do
      user_hash_post = build_user_hash_post

      puts "user: #{user_hash_post.inspect}"
      #
      visit Myconfig::HUB_HOST + 'users/new'

      # fill form
      f = find('form#new_user')
      r = user_hash_post
      f.fill_in 'user_email', :with => r[:email]
      f.fill_in 'user_username', :with => r[:username]
      f.fill_in 'user_team_attributes_name', :with => r[:teamname]
      f.fill_in 'user_firstname', :with => r[:firstname]
      f.fill_in 'user_lastname', :with => r[:lastname]
      f.fill_in 'user_password', :with => r[:password]
      f.fill_in 'user_password_confirmation', :with => r[:password]


      f.find('input[type=submit]').click

      #
      expect(current_path).to match /users\/created/



    end

  end


  describe 'create and verify user' do
    before :each do
      TestEmailRedis::Helpers.clean_emails_all
    end

    it "verify user via API" do
      user_hash_post = build_user_hash_post

      # create not verified
      resp = api_do_request :post, 'users', user_hash_post, {}
      resp_data = JSON.parse(resp.body)

      # token in email
      mail = TestEmailRedis::Helpers.get_last_email_for_user user_hash_post[:email]

      token = api_mail_get_verification_token_from_email(mail)

      # verify
      resp = api_do_request :post, 'users/verify', {verificationToken: token}, {}

      # check
      expect(resp.code).to eq 200

      resp_data = parse_resp_data(resp)

      puts "res: #{resp_data.inspect}"

      res_cluster = resp_data['cluster']
      expect(res_cluster['id']).to be_truthy
      expect(res_cluster['name']).to be_truthy
      expect(res_cluster['domainname']).to be_truthy

      # team
      res_team = resp_data['cluster']['team']
      expect(res_team['id'].length).to be > 2
      expect(res_team['name'].length).to be > 2

    end

    it 'verify user via site' do
      raise ' TODO '
    end
  end

end

