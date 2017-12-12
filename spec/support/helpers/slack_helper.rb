module SlackHelper

  @@gex_col = '#1d87e4'
  @@green_col = '#00C853'
  @@red_col = '#E53935'
  @@orange_col = '#1d87e4'
  @@website_col = '#7C4DFF'
  @@partner_col = '#D500F9'

  def self.get_client
    Slack::Web::Client.new
  end


  def self.get_channel
    ENV['slack_channel'] || '#main_tests_result'
  end

  def self.test_send(res)
    mess = test_template(res)

    web_client = get_client
    channel = get_channel
    send_message(web_client, channel, mess)
  end


  def self.test_template(data)
    info = data[:data]
    col = data[:passed] ? @@green_col : @@red_col
    system = ENV['system'] || 'MAIN'
    return_att("#{system}  \nTest passed: #{data[:passed]}", "\n#{data[:event]}", info, col)
  end


  def self.send_message(web_client, channel, message)
    if message[:type]==:text
      web_client.chat_postMessage(channel: channel, as_user: true, text: message[:text])
    else
      web_client.chat_postMessage(channel: channel, as_user: true, attachments: message[:att])
    end
  end

  def self.return_att(pre_text, title, text, color)
    {
        :type => :att,
        :att =>
            [{
                 pretext: pre_text,
                 title: title,
                 text: text,
                 color: color
             }]
    }
  end

  def return_mess(text)
    {
        :type => :mess,
        :text => text
    }
  end
end