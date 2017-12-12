module ApiHelpers

  def api_do_request(method, u, data, headers={})
    #require 'http'

    u.sub!(/^\//, '')

    url = Myconfig::HUB_HOST + u

    #response = HTTParty.get('http://api.stackexchange.com/2.2/questions?blocks=stackoverflow')
    #puts response.body, response.code, response.message, response.headers.inspect

    headers['Content-Type'] = "application/json"
    headers['Accept'] = "application/json"

    # do http request

    request_params = {:query=>data, :headers => headers}
    request_params[:timeout] = 500

    if method==:post
      response = HTTParty.post(url, request_params)
    elsif method==:get
      response = HTTParty.get(url, request_params)
    elsif method==:put
      response = HTTParty.put(url, request_params)
    elsif method==:delete
      response = HTTParty.delete(url, request_params)
    end

    #unless [200, 201].include? response.code
    #  raise 'Error API request'
    #end


    return response
    #return resp_data
  end


  def api_download_file(filename, u, data, headers)
    puts "save to file #{filename} from #{u}"
    u.sub!(/^\//, '')

    url = Myconfig::HUB_HOST + u

    #headers['Content-Type'] = "application/json"
    #headers['Accept'] = "application/json"

    # do http request
    request_params = {:query=>data, :headers => headers}
    request_params[:timeout] = 500


    resp = HTTParty.get(url, request_params)
    File.open(filename, "wb") do |f|
      f.binmode
      f.write resp.body
      #f.write resp.parsed_response
      f.close
    end
  end

  def parse_resp_data(response)
    resp_data = JSON.parse(response.body)
  end



end
