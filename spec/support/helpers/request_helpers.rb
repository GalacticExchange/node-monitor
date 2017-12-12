module RequestHelpers

  def last_response
    response
  end

  def response_json
    JSON.parse(response.body)
  end

  def post_json(url, data, headers={})
    headers['HTTP_ACCEPT'] =  "application/json"
    post url, data, headers
  end

  def put_json(url, data, headers={})
    headers['HTTP_ACCEPT'] =  "application/json"
    put url, data, headers
  end



  def get_json(url, data, headers={})
    headers['HTTP_ACCEPT'] =  "application/json"
    get url, data, headers
  end

  def delete_json(url, data, headers={})
    headers['HTTP_ACCEPT'] =  "application/json"
    delete url, data, headers
  end

end
