module ApiAuthHelpers
  def api_auth(username, pwd)

    resp = api_do_request :post, 'login', {username: username, password: pwd}, {}

    #puts "auth body: #{resp.body}"

    data = JSON.parse(resp.body)

    return data['token']
  end
end
