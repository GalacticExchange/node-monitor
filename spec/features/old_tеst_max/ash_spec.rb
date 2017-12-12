RSpec.describe "Login user ", :type => :request do

  use_headless

  describe "login" do
    before :each do
      TestEmailRedis::Helpers.clean_emails_all
    end
    after :each do
      sign_out
    end

    # unless Gem.win_platform?
    #   headless = Headless.new(dimensions: "1600x900x24", display: 99, autopick: true, reuse: false, destroy_at_exit: true).start
    # end



    it 'user login'  do
      # user login
      fill_in 'user_login', :with => "halk"
      fill_in 'user_password', :with => 'Password1'
      puts "Title = #{$driver.title}"
      puts "Title = #{$driver.inspect}"
      $driver.save_screenshot "/home/alex/tests/screenshots/ss3.png"
      # headless.take_screenshot "/home/alex/tests/screenshots/ss3.png"


      login_button.click
      $driver.save_screenshot "/home/alex/tests/screenshots/ss4.png"

      title = find('[data-div="page-title"]')
      title.find('h2').text.should == 'Create cluster'
      title.find('p').text.should == 'Step 1: Choose the type.'
      puts "Title = #{@driver.title}"

    end

  end

end

