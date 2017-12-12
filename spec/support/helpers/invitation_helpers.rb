module InvitationHelpers
  def invitation_get_accept_link_from_email(mail)
    # get link from email
    link = nil
    begin
      html = mail['parts'][0]['body']
      link = (/(http:\/\/[a-z\:\/\d]+\/inviteaccept\/[a-z\d]+)\s+/.match(html).captures rescue nil)
    rescue => e
    end

    if link.is_a? Array
      link = link[0]
    end

    link
  end
end

