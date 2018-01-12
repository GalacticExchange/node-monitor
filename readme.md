# new line added for testing Jenkins trigger
# Install

bundle install

* !!! IMPORTANT !! to run UI tests - check Selenium and Firefox versions.

* Compatibility condition: Selenium Version: 0.2.11  --  Firefox v.41.0.2

or
* Selenium Webdriver 2.53.0 works with Firefox 46.0. 

You can find the the mentioned version at https://support.mozilla.org/en-US/kb/install-older-version-of-firefox .

# Set up ENV variable for environment
gex_env=main;
JRUBY_OPTS=-X+O

# Set up Capybara to open electron apps

Selenium::WebDriver::Chrome.driver_path = 'path_to_electron_chromedriver'

Capybara.register_driver :selenium do |app|
  caps = Selenium:: ::Remote::Capabilities.chrome("chromeOptions" => {"binary" => 'path_to_electron_application'})
  $driver = Capybara::Selenium::Driver.new(app, {:browser => :chrome, :desired_capabilities => caps})
end
Capybara.configure do |config|
  config.default_driver = :selenium
  config.javascript_driver = :selenium
end


# Check test

* test UI

RAILS_ENV=main rspec spec/features/temp1_spec.rb 
RAILS_ENV=main rspec spec/features/temp1_spec.rb -e "open home page"




# run test
RAILS_ENV=main rspec spec/features/testname_spec.rb -e "test name" 


# install gexd program on a specific machine

* install gexd
```
gex_env=main client=client1 rspec spec/features/gexd/gexd_spec.rb -e "install gexd"
```
it uses config file from data/gex/config.$gex_env.properties
and config for client machine from data/clients/ $client .json


* edit `data/clients/<your_machine>.json` with your machine settings

* edit visudo 

```
sudo visudo 
  
# add line in the end for your user
  
myuser ALL=(ALL) NOPASSWD: ALL
  
``` 


* run command:

```
# main
RAILS_ENV=main username=mike-mcclure user_pwd=Password1 client=client1 rspec spec/features/gexd/gexd_spec.rb -e "install gexd"

# prod
RAILS_ENV=prod username=mike-mcclure user_pwd=Password1 client=client1 rspec spec/features/gexd/gexd_spec.rb -e "install gexd"
```


* check what is installed

```
cat /etc/gex/config.properties

# check properties

```





# Create user

* App environments:
     * development
     * main
     * production
     
     
## create not verified user


### create not verified user via site

```
RAILS_ENV=main rspec spec/features/users/users_create_spec.rb -e "create user with site"
```

RAILS_ENV=main password=Password1 rspec spec/features/users/users_create_ui_spec.rb -e "create user"



* with password
RAILS_ENV=main password=Password1 rspec spec/features/users_create_spec.rb -e "create user with site"

RAILS_ENV=main password=Password1 rspec spec/features/users/users_create_spec.rb -e "create user with site"



### create not verified user via API

RAILS_ENV=development rspec spec/features/users/users_create_spec.rb -e "create user with API"


## create verified user via API

* with random password
RAILS_ENV=devlocalserver rspec spec/features/users_create_spec.rb -e "verify user via API" 

* with password
RAILS_ENV=devlocalserver password=Password1 rspec spec/features/users/users_create_spec.rb -e "verify user via API" 


### Create user with enterprise options

* production, cloudera cluster
// email will be XXX@gex.io

gex_env=prod password=Password1 hadoop_type=cdh rspec spec/features/users/users_create_enterprise_spec.rb -e "create cluster"


* main ENV, cloudera cluster
gex_env=main password=Password1 hadoop_type=cdh rspec spec/features/users/users_create_enterprise_spec.rb -e "create cluster"


* with username
gex_env=main username=kh1 password=Password1 hadoop_type=cdh rspec spec/features/users/users_create_enterprise_spec.rb -e "create cluster"


# Create AWS cluster

* for existing user
```
gex_env=main username=kh0 user_pwd=Password1 aws_config=keys1 hadoop_type=cdh rspec spec/features/clusters/cluster_create_aws_spec.rb -e "create cluster"
```




# Install node

* install node on a specific machine

RAILS_ENV=main username=malika-schimmel user_pwd=Password1 client=client1 rspec spec/features/nodes/nodes_install_spec.rb -e "install node on client"




 
# Install app on virtualbox node

* install app on node in virtualbox

RAILS_ENV=devlocalserver username=ibrahim user_pwd=Password1 client=client1 app=rocana rspec spec/features/apps/install_virtualbox_node_spec.rb -e "install app on node"

* install app with custom config.json
RAILS_ENV=devlocalserver username=mike-mcclure user_pwd=Password1 client=client1 app=rocana app_config=rocana_cloudera rspec spec/features/apps/apps_install_virtualbox_node_spec.rb -e "install app on node"




# Uninstall app

* install app on node in virtualbox

RAILS_ENV=devlocalserver username=ibrahim user_pwd=Password1 client=client1 app=rocana app_uid=123213 rspec spec/features/apps/apps_uninstall_spec.rb -e "uninstall existing app"




# Test servers with Serverspec

## basic example

* edit connection settings in `data/servers/servers.json`:

```
  "mylocal": {"type": "ssh", "host": "10.1.0.12", "user": "mmx", "password": "Password1"},


```

here server name is 'mylocal'.


## run tests for the server

* run all tests for the server
```
gex_env=main rake serverspec: <server_name>
```

* run specific test

```
gex_env=main rake serverspec: <server>_network
gex_env=main rake serverspec: <server>_elasticsearch
```

example:
* run test located in `spec/servers/mylocal/base_spec.rb`

```
rake serverspec:mylocal_base
```


* pass arguments to test

```
// with options

gex_env=main host=10.1.0.12 user=mmx pwd=Password1 rake serverspec:mylocal_base

```



# Test servers in gexcloud


## main host server

```
gex_env=main rake serverspec:mainhost
gex_env=main rake serverspec:mainhost_base

gex_env=main host=51.1.0.50 user=gex pwd=Password1 rake serverspec:mainhost_base
```

rake  gex_env=dev serverspec:mainhost_api_conn


## Test dns server

```
gex_env=main rake serverspec:dns_network
```

## Test API server

* run all tests
```
gex_env=main rake serverspec:api
```

* run specific test
```
gex_env=main rake serverspec:api_network
gex_env=main rake serverspec:api_elasticsearch
```








# Test cluster

## Test master node

requirements

* run from machine which has access to master host machine

* edit config for the master machine `data/servers_custom/ cluster_master.json` - main server

```
{
  "type": "ssh", "host": "10.0.2.15", "user": "vagrant", "password": "vagrant"
}
```

* run
```
gex_env=main server=cluster_master cluster_id=11 rake serverspec:cluster_master
```

* or specify params in command line
```

# prod
gex_env=prod cluster_id=11 gex_user=myuser gex_pwd=Password1 server=cluster_master server_host=gex1.galacticexchange.io server_user=root server_pwd=Password1 rake serverspec:cluster_master


# main
gex_env=main gex_user=myuser gex_pwd=Password1 host=51.1.0.50 user=gex pwd=Password1 rake serverspec:cluster_master_hadoop_container
```




## Test node

* test node with serverspec

* test LOCAL node 

```
gex_env=prod server=node_local rake serverspec:cluster_node
```


* test node by IP

* edit connection for node 

* edit file for server `data/servers_custom/ <your_name> .json`.

see example in data/servers_custom/example_node.json

```
{
  "type": "ssh", "host": "10.0.2.15", "user": "vagrant", "password": "vagrant"
}
```


* run test

```

# from file data/servers_custom/node1.json
gex_env=main server=node1 rake serverspec:cluster_node


# specific test
gex_env=main server=node1 rake serverspec:cluster_node_sensu
```

or 
```
???
RAILS_ENV=main gex_user=mike-mcclure gex_pwd=Password1 host=51.77.39.105 user=root pwd=Password1 rake serverspec:master_hadoop_container
```







# Test application 

## Test application Docker container on client node

