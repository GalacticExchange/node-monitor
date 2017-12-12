module Element
=begin
 AWS_REGION_USE1 = "US East (N. Virginia - us-east-1)"
 AWS_REGION_USE2 = "US East (Ohio - us-east-2)"
 AWS_REGION_USW1 = "US West (N. California - us-west-1)"
 AWS_REGION_USW1 = "US West (Oregon - us-west-2)"
 AWS_REGION_CANADA = "Canada (Central - ca-central-1)"
 AWS_REGION_IRELAND = "EU (Ireland - eu-west-1)"
 AWS_REGION_EU1 = "EU (Frankfurt - eu-central-1)"
 AWS_REGION_EU2 = "EU (London - eu-west-2)"
 AWS_REGION_ASIA_PACIFIC1 = "Asia Pacific (Tokyo - ap-northeast-1)"
 AWS_REGION_ASIA_PACIFIC2 = "Asia Pacific (Seoul - ap-northeast-2)"
 AWS_REGION_ASIA_PACIFIC3 = "Asia Pacific (Singapore - ap-southeast-1)"
 AWS_REGION_ASIA_PACIFIC4 = "Asia Pacific (Sydney - ap-southeast-2)"
 AWS_REGION_ASIA_PACIFIC5 = "Asia Pacific (Mumbai - ap-south-1)"
 AWS_REGION_SOUTH_AMERICA = "South America (São Paulo - sa-east-1)"
=end
  KEY_ID = 'AKIAJIR6QGWWQUSGCG3A'
  ACCESS_KEY = '3e4g6Igyd982dJncJaY6y9kH4T13yv8czXNcVekW'


  def registration_form
    find('form#new_user')
  end

  def login_button
    find('[data-btn="login"]')
  end

  def sign_up_link
    find('[data-link="sign-up"]')
  end

  def sign_up_button
    find('[data-btn="sign-up"]')
  end

  def sign_in_button
    find('[data-btn="sign-in"]')
  end

  def avatar_icon
    find('#avatar_drop')
  end

  def get_master_gex_ip(cluster_uid)
    x = page.all('td').text
    y = x.split(' ')
    return y.last
  end


  ####
=begin
  def method_missing(method, *args, &block)
    if method.to_s =~ /^find_(.*)$/
      const = self.class.const_get($1.upcase)
      send(:find, const)
    else
      super
    end

  end
=end

  ####
  def on_premise_card
    first('[data-div="on-premise-card"]')
  end

  def aws_card
    find('[data-div="aws-card"]')
  end

  def next_btn
    find('.lg-icon.gex-svg')
  end

  def next_step_btn
    find('[data-btn="select-components"]')
  end

  def using_of_saved_key
    find('[ng-click="selectKey(key)"]').click
  end

  def create_cluster_button
    find('button', :text => 'Create cluster')
  end

  def create_on_premise_button
    on_premise_card.find('[data-btn="on-premise-btn"]')
  end

  def create_aws_button
    aws_card.find('[data-btn="aws-btn"]')
  end

  def create_on_premise_cluster_btn
    find('[data-btn="create-onprem"]')
  end

  def create_aws_cluster_btn
    find('[data-btn="create-aws"]')
  end

  def sign_out_button
    find('[data-btn="sign-out"]')
  end

  def sign_out_message
    find('[data-block="flash-msg"]').text
  end

  def logotype
    find('[data-div="logo"]')
  end

  def main_menu
    find('[data-block="main_menu"]')
  end

  def nodes_tab
    main_menu.find('[data-div="nodes-tab"]')
  end

  def big_data_tab
    main_menu.find('[data-div="big-data-tab"]')
  end

  def transform_tab
    main_menu.find('[data-div="trans-tab"]')
  end

  def search_visualize_tab
    main_menu.find('[data-div="vis-tab"]')
  end

  def stats_tab
    main_menu.find('[data-div="stats-tab"]')
  end
  def containers_tab
    main_menu.find('[data-div="containers-tab"]')
  end

  def app_hub_tab
    main_menu.find('[data-div="apphub-tab"]')
  end

  def installed_apps_tab
    main_menu.find('[data-div="installed-apps-tab"]')
  end

  def add_nodes_btn
    find('[data-btn="add-node"]')
  end

  def local_node_card
    find('[data-div="local-node-card"]')
  end

  def core_node_card
    find('[data-div="core-node-card"]')
  end

  def app_only_node_card
    find('[data-div="app-node-card"]')
  end

  def install_app_only_node_btn
    find('[data-btn="app-only-node"]')
  end

  def install_remote_node_btn
    find('[data-btn="add-remote-nodes"]')
  end

  def install_node_button
    find('[ng-click="installNode()"]')
  end


  def add_aws_node_btn
    find('[ng-click="addNodes()"]')
  end

  def fill_in_hostname_ip_field(hostname_or_ip)

  end

  def fill_in_machine_username_field(machine_username)

  end

  def fill_in_machine_user_pwd(pwd)

  end

  def main_window
    page.driver.browser.window_handles.first
  end

  def pop_up
    page.driver.browser.window_handles.last
  end

  def skip_button
    find('[ng-click="skipCustomName()"]')
  end

  def set_cstom_name_btn
    find('[ng-click="setCustomName()"]')
  end

  def ok_button
    find('div[data-btn="popup-ok-btn"]')
  end

  def yes_button
    find('[data-btn="popup-yes-btn"]')
  end

  def node_list
    find('#list-nodes')
  end

  def local_node
    node_list.find('[data-text="local-node"]', :text => '(local)')
  end

  def node_state
    first('[data-div="node-state"]').text
  end

  def status_checks
    first('[data-div="status-checks"]').text
  end

  def settings_app_button
    find('[data-btn="settings-btn"]')
  end

  def settings_node_button
    find('[data-btn="node-settings-btn"]')
  end

  def uninstall_button
    find('[data-btn="uninstall-node"]')
  end

  def uninstall_app_button
    find('[data-btn="uninstall-app"]')
  end

  def reinstall_button
    find('[data-btn="reinstall-node"]')
  end

  def remove_button
    find('[data-btn="remove-node"]')
  end

  def force_uninstall_button
    find('[ng-click="uninstallNodeForce()"]')
  end

  def stop_button
    find('[data-btn="stop-node"]')
  end

  def start_button
    find('[data-btn="start-node"]')
  end

  def restart_button
    find('[data-btn="restart-node"]')
  end

  def datameer_card
    find('#datameer_card')
  end

  def dataenchilada_card
    find('#data_enchilada_card')
  end

  def rocana_card
    find('#rocana_card')
  end

  def zoomdata_card
    find('#zoomdata_card')
  end
  def scraper_card
    find('#scraper_card')
  end
  def scraper_install_link
    scraper_card.find('[data-btn="install"]')
  end

  def scraper_open_link
    scraper_card.find('[data-btn="open"]')
  end

  def datameer_install_link
    datameer_card.find('[data-btn="install"]')
  end

  def datameer_open_link
    datameer_card.find('[data-btn="open"]')
  end

  def dataenchilada_install_link
    dataenchilada_card.find('[data-btn="install"]')
  end

  def dataenchilada_open_link
    dataenchilada_card.find('[data-btn="open"]')
  end

  def rocana_install_link
    rocana_card.find('[data-btn="install"]')
  end

  def zoomdata_install_link
    zoomdata_card.find('[data-btn="install"]')
  end

  def zoomdata_open_link
    zoomdata_card.find('[data-btn="open"]')
  end

  def rocana_open_link
    rocana_card.find('[data-btn="open"]')
  end

  def config_top
    find('#install_config_top')
  end

  def install_button
    config_top.find('[data-btn="continue"]')
  end

  def app_state
    find('[data-div="state"]').text
  end

  def datameer
    find('[data-row="app-datameer"]')
  end
  def dataenchilada
    find('[data-row="app-data_enchilada"]')
  end
  def scraper
    find('[data-row="app-scraper"]')
  end

  def service_block
    find('[data-div="services-list"]')
  end

  def web_ui_block
    service_block.find('#webui_block')
  end

  def app_public_ip
    public_ip = web_ui_block.find('#webui_public_ip').text
    public_ip
    puts public_ip
  end

  def app_port
    port = web_ui_block.find('#webui_port').text
    port
    puts port
  end


  def go_to_clusters_page
    cluster_dd_block = find('#cluster_actions_drop')
    cluster_dd_menu = cluster_dd_block.find('.pull-right')
    cluster_dd_menu.click
    all_clusters_tab = find('.hover-el', :text => 'All clusters')
    all_clusters_tab.click
  end

  def clusters_button
    find('#clusters_btn')
  end

  def team_clusters_tab
    find('[data-div="team_clusters"]')
  end

  def cluster_block(cluster_uid)
    cluster_selector = "[data-div=\"cluster-#{cluster_uid}\"]"
    find(cluster_selector)
  end

  def cluster_state(cluster_uid)
    find("[data-div=\"cluster-#{cluster_uid}\"] [data-div=\"cluster-state\"]").text
  end

  def delete_cluster(cluster_uid)

    cluster_selector = "[data-div=\"cluster-#{cluster_uid}\"]"
    cluster_block = find(cluster_selector)
    cluster_block.find('[div-block="do_settings_visible"]').click
    uninstall_cluster_btn = find('[data-btn="uninstall-cluster"]').click
  end
  def delete_cluster_with_node(cluster_uid)

    cluster_selector = "[data-div=\"cluster-#{cluster_uid}\"]"
    cluster_block = find(cluster_selector)
    cluster_block.find('[div-block="do_settings_visible"]').click
    uninstall_cluster_btn = find('[data-btn="uninstall-cluster-all"]').click
  end

  def switch_to_cluster(cluster_uid)
    cluster_selector = "[data-div=\"cluster-#{cluster_uid}\"]"
    cluster_block = find(cluster_selector)
    cluster_block.find('[data-div="cluster-state"]').click
  end

  def select_node(node_uid)
    find("[data-div=\"#{node_uid}\"]")
  end


  def go_to_stats_node_page
    find('[data-link="open-stats"]').click
  end

  def sign_out
    avatar_icon.click
    sign_out_button.click
  end

  def click_on_the_back_button
    find('[data-btn="back-btn"]').click
  end




end


