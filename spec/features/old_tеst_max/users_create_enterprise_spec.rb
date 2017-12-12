RSpec.describe "Create user with enterprise options", :type => :request do

  before :each do
    TestEmailRedis::Helpers.clean_emails_all
  end


  describe 'context - create cluster' do

    it "create cluster" do

      ent_options = {
          enterprise: 1,
          hadoopType: ENV['hadoop_type'],
      }


      user_hash_post = build_user_hash_post(nil, ent_options)

      #puts "user: #{user_hash_post.inspect}"

      # create not verified
      resp = api_do_request :post, 'users', user_hash_post, {}

      expect(resp.code).to eq 200
      resp_data = JSON.parse(resp.body)

      # token in email
      mail = TestEmailRedis::Helpers.get_last_email_for_user user_hash_post[:email]

      token = api_mail_get_verification_token_from_email(mail)

      puts "token from email=#{token}"

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


  end

end

