module SlackMsgHelper

  def slack_msg_create_cluster(passed, user_name, user_id, cluster_type, cluster_name, cluster_id, cluster_uid, test_exception)
    if passed
      SlackHelper.test_send({
                                passed: passed,
                                event: "CREATE #{cluster_type} CLUSTER",
                                data: <<-EOF
          Info:
          User: #{user_name}, id: #{user_id}
          Cluster: name: #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
                                EOF
                            })
    else
      SlackHelper.test_send({
                                passed: passed,
                                event: "CREATE #{cluster_type} CLUSTER",
                                data: <<-EOF
          Info:
          User: #{user_name}, id: #{user_id}
          Cluster: name: #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
          Exception:
               #{test_exception}
                                EOF
                            })

    end

  end
  def slack_msg_check_cluster(passed, user_name, cluster_type, cluster_name, cluster_id, tests_passed, tests_failed)
    if passed

      SlackHelper.test_send({
                                passed: passed,
                                event: "VERIFY #{cluster_type} CLUSTER CONDITION",
                                data: <<-EOF

      Info:
          User: #{user_name}
          Cluster:  #{cluster_name}, id: #{cluster_id}

      :white_check_mark:Passed tests:
               #{tests_passed}
                                EOF
                            })
    else
      SlackHelper.test_send({
                                passed: passed,
                                event: "VERIFY #{cluster_type} CLUSTER CONDITION",
                                data:
                                    <<-EOF

      Info:
          User: #{user_name}
          Cluster:  #{cluster_name}, id: #{cluster_id}
      :exclamation:Failed tests:
               #{tests_failed}
      :white_check_mark:Passed tests:
                 #{tests_passed}

                                EOF
                            })

    end
  end

  def cluster_uninstallation(passed, user_name, cluster_type, cluster_name, cluster_id, cluster_uid, test_exception)
    if passed
      SlackHelper.test_send({
                                passed: passed,
                                event: "DELETE #{cluster_type} CLUSTER",
                                data: <<-EOF
          Info:
          User: #{user_name}
          Cluster: name: #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
                                EOF
                            })
    else
      SlackHelper.test_send({
                                passed: passed,
                                event: "DELETE #{cluster_type} CLUSTER",
                                data: <<-EOF
          Info:
          User: #{user_name}
          Cluster: name: #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
          Exception:
               #{test_exception}
                                EOF
                            })

    end
  end

  def verify_cluster_uninstallation(passed, user_name, cluster_type, cluster_name, cluster_id, tests_passed, tests_failed)
    if passed
      SlackHelper.test_send({
                                passed: passed,
                                event: "VERIFY #{cluster_type} CLUSTER UNINSTALLATION",
                                data: <<-EOF

      Info:
            User: #{user_name}
            Cluster: #{cluster_name}, id: #{cluster_id}

            :white_check_mark:Passed tests:
               #{tests_passed}
                                EOF
                            })
    else

      SlackHelper.test_send({
                                passed: passed,
                                event: "VERIFY #{cluster_type} CLUSTER UNINSTALLATION",
                                data:
                                    <<-EOF

      Info:
            User: #{user_name}
            Cluster: #{cluster_name}, id: #{cluster_id}

            :exclamation:Failed tests:
               #{tests_failed}
            :white_check_mark:Passed tests:
                 #{tests_passed}

                                EOF
                            })

    end
  end

  def slack_msg_add_node(passed, user_name, node_type, cluster_name, cluster_id,  cluster_uid, node_name, node_uid, test_exception)
    if passed
      SlackHelper.test_send({
                                passed: passed,
                                event: "ADD #{node_type} NODE",
                                data: <<-EOF
          Info:
          User: #{user_name}
          Cluster:  #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
          Node: #{node_name}, uid: #{node_uid}
                                EOF
                            })
    else
      SlackHelper.test_send({
                                passed: passed,
                                event: "ADD #{node_type} NODE",
                                data: <<-EOF
          Info:
          User: #{user_name}
          Cluster: name: #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
          Node: #{node_name}, uid : #{node_uid}
          Exception: #{test_exception}
                                EOF
                            })
    end
  end

  def check_node_condition(passed, user_name, node_type, cluster_name, cluster_id, node_name, node_public_ip, tests_passed, tests_failed)
    if passed
      SlackHelper.test_send({
                                passed: passed,
                                event: "VERIFY #{node_type} NODE CONDITION",
                                data: <<-EOF

      Info:
            User: #{user_name}
            Cluster: #{cluster_name}, id: #{cluster_id}
            Node: #{node_name}, node_public_ip  #{node_public_ip}

            :white_check_mark:Passed tests:
               #{tests_passed}
                                EOF
                            })
    else

      SlackHelper.test_send({
                                passed: passed,
                                event: "VERIFY #{node_type} NODE CONDITION",
                                data:
                                    <<-EOF

      Info:
            User: #{user_name}
            Cluster: #{cluster_name}, id: #{cluster_id}
            Node: #{node_name}, node_public_ip  #{node_public_ip}
            :exclamation:Failed tests:
               #{tests_failed}
            :white_check_mark:Passed tests:
                 #{tests_passed}

                                EOF
                            })

    end
  end


  def slack_msg_verify_node_services(passed, user_name, type_node, cluster_name, cluster_id, cluster_uid, node_name, node_uid, tests_passed, tests_failed)
    if passed
      SlackHelper.test_send({
                                passed: passed,
                                event: "CHECK #{type_node} NODE SERVICES",
                                data: <<-EOF

      Info:
            User: #{user_name}
            Cluster: #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
            Node: #{node_name}, uid: #{node_uid}

            Passed tests:
               #{tests_passed}
                                EOF
                            })

    else

      SlackHelper.test_send({
                                passed: passed,
                                event: "CHECK #{type_node} NODE SERVICES",
                                data:
                                    <<-EOF

      Info:
            User: #{user_name}
            Cluster: #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
            Node: #{node_name}, uid: #{node_uid}

            Failed tests:
               #{tests_failed}
            Passed tests:
                 #{tests_passed}

                                EOF
                            })

    end

  end

  def slack_msg_uninstall_node(passed, user_name, node_type, cluster_name, cluster_id, cluster_uid, node_name, node_uid, test_exception)
    if passed
      SlackHelper.test_send({
                                passed: passed,
                                event: "UNINSTALL #{node_type} NODE",
                                data: <<-EOF
          Info:
                User: #{user_name}
                Cluster: #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
                Node: #{node_name}, uid: #{node_uid}
                                EOF
                            })
    else
      SlackHelper.test_send({
                                passed: passed,
                                event: "UNINSTALL #{node_type} NODE",
                                data: <<-EOF
          Info:
                User: #{user_name}
                Cluster: name: #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
                Node: #{node_name}, uid: #{node_uid}
                Exception:
                          #{test_exception}
                                EOF
                            })
    end
  end

  def slack_msg_add_app(passed, user_name, node_type, app_name, cluster_name, cluster_id,  cluster_uid, node_name, test_exception)
    if passed
      SlackHelper.test_send({
                                passed: passed,
                                event: "#{app_name} INSTALLATION ON #{node_type} NODE",
                                data: <<-EOF
          Info:
          User: #{user_name}
          Cluster:  #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
          Node: #{node_name}
                                EOF
                            })
    else
      SlackHelper.test_send({
                                passed: passed,
                                event: "#{app_name} INSTALLATION ON #{node_type} NODE",
                                data: <<-EOF
          Info:
          User: #{user_name}
          Cluster: name: #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
          Node: #{node_name}
          Exception: #{test_exception}
                                EOF
                            })
    end


  end

  def slack_msg_uninstall_app(passed, user_name, node_type, app_name, cluster_name, cluster_id,  cluster_uid, node_name, test_exception)
    if passed
      SlackHelper.test_send({
                                passed: passed,
                                event: "#{app_name} UNINSTALLATION ON #{node_type} NODE",
                                data: <<-EOF
          Info:
          User: #{user_name}
          Cluster:  #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
          Node: #{node_name}
                                EOF
                            })
    else
      SlackHelper.test_send({
                                passed: passed,
                                event: "#{app_name} UNINSTALLATION ON #{node_type} NODE",
                                data: <<-EOF
          Info:
          User: #{user_name}
          Cluster: name: #{cluster_name}, id: #{cluster_id}, uid: #{cluster_uid}
          Node: #{node_name}
          Exception: #{test_exception}
                                EOF
                            })
    end

  end


  def slack_msg_check_user_account(passed, user_name,  cluster_name, node_name, test_exception)
    if passed
      SlackHelper.test_send({
                                passed: passed,
                                event: "CHECKING USER ACCOUNT",
                                data: <<-EOF
          Info:
          User: #{user_name}
          Cluster:  #{cluster_name}
          Node: #{node_name}
                                EOF
                            })
    else
      SlackHelper.test_send({
                                passed: passed,
                                event: 'CHECKING USER ACCOUNT',
                                data: <<-EOF
          Info:
          User: #{user_name}
          Cluster: name: #{cluster_name}
          Node: #{node_name}
          Exception: #{test_exception}
                                EOF
                            })
    end
  end

end