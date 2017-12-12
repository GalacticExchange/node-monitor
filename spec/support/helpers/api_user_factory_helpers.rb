module ApiUserFactoryHelpers

  def build_user_password
    s = ENV['password']
    if s.nil? || s.to_s==''
      s = Faker::Internet.password(8)
    end

    s
  end

  def build_username
    s = ENV['username']
    if s.nil? || s.to_s==''
      s = Faker::Internet.user_name(nil, ['-'])
    end

    s
  end

  def build_user_hash
    u = build_username
    res = {
        teamname: Faker::Internet.user_name(nil, ['-']),
        username: u,
        #email: Faker::Internet.email,
        #email: Faker::Internet.user_name+'@galacticexchange.io',
        email: u+'@galacticexchange.io',
        password: build_user_password,
        firstname: Faker::Name.first_name,
        lastname: Faker::Name.last_name,
    }

  end

  def build_user_hash_post(user_hash=nil, extra_fields={})
    user_hash ||= build_user_hash

    h = user_hash

    #
    extra_fields.each do |f,v|
      if v.is_a?(TrueClass) || v.is_a?(FalseClass)
        h[f] = v ? 1 : 0
      else
        h[f] = v
      end

    end

    #
    h
  end

  def api_create_user(user_hash)
    api_do_request :post, 'users', user_hash, {}
  end

  def api_verify_user(token)
    api_do_request :post, 'users/verify', {verificationToken: token}, {}
  end


  def api_create_user_verified(user_hash_post)
    res = api_create_user(user_hash_post)

    # get token from email
    mail = TestEmailRedis::Helpers.get_last_email_for_user user_hash_post[:email]

    token = api_mail_get_verification_token_from_email(mail)

    # verify
    res_verify = api_verify_user(token)


  end


  ### helper methods

  def api_mail_get_verification_token_from_email(mail)
    # get link from email
    token = nil
    begin
      html = mail['parts'][0]['body']
      token = (/\/verify\/([a-z\d]+)\s+/.match(html).captures rescue nil)
    rescue => e
    end

    if token.is_a? Array
      token = token[0]
    end

    token
  end



  # get link from email
  def mail_get_resetpwd_token_from_email(mail)
    token = nil
    begin
      html = mail['parts'][0]['body']
      token = (/\/resetpassword\/([a-z\d]+)\s+/.match(html).captures rescue nil)
    rescue => e
    end

    if token.is_a? Array
      token = token[0]
    end

    token
  end

end
