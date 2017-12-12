module NodeHelpers

  def get_node_id_on_client(client)
    res = run_cmd_on_client(client, "gex node info")
    output = res[:output]
    puts "node info: #{output}"
    #output = 'Id: 123\n3333'
    #output = 'Id: \t\t\t1618741016765763\n\tName:'
    r = output.match /Id:[\s\t]*(\d+)\n/i
    return nil if r.nil?
    node_uid = r[1]

    node_uid
  end
end

