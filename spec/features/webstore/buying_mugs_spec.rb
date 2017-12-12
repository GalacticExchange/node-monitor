RSpec.describe "Webstore", :type => :request do

  # gex_env=main browser=chrome rspec spec/features/webstore/buying_mugs_spec.rb

  describe 'buying mugs' do

    before :all do
      visit('http://shop.galacticexchange.io/')
      find('a', :text => 'Login').click
      find('[type="email"]').set('julia@galacticexchange.io')
      find('[type="password"]').set('12345678')
      find('[value="Login"]').click
    end

    after :all do
      find('a', :text => 'Logout').click
    end

    it 'buying mug  Ruby on Rails Mug' do
      for i in 0..5 do
        find('.list-group-item', :text => 'Mugs').click
        find('[title="Ruby on Rails Mug"]').click
        find('[id="quantity"]').set('4')
        find('button', :text => 'Add To Cart').click

        find('.cart-info').click
        sleep 3
        find('button', :text => 'Checkout').click
        find('[value="Save and Continue"]').click
        find('[value="Save and Continue"]').click
        find('[value="Save and Continue"]').click
        find('[value="Place Order"]').click

        puts "*******************"
        puts find('.alert-notice').text
        first('.alert-notice').text.should == 'Your order has been processed successfully'

        find('a', :text => 'Home').click
        puts i
      end
    end


    it 'buying mug  Ruby on Rails Stein' do

      for i in 0..8 do

        find('.list-group-item', :text => 'Mugs').click
        find('[title="Ruby on Rails Stein"]').click
        find('[id="quantity"]').set('1')
        find('button', :text => 'Add To Cart').click

        find('.cart-info').click
        sleep 3
        find('button', :text => 'Checkout').click
        find('[value="Save and Continue"]').click
        find('[value="Save and Continue"]').click
        find('[value="Save and Continue"]').click
        find('[value="Place Order"]').click

        puts "*******************"
        puts find('.alert-notice').text
        first('.alert-notice').text.should == 'Your order has been processed successfully'
        find('a', :text => 'Home').click
        puts i
      end
    end


  it 'buying mug Spree Stein' do

    for i in 0..15 do
      find('.list-group-item', :text => 'Mugs').click
      find('[title="Spree Stein"]').click
      find('[id="quantity"]').set('5')
      find('button', :text => 'Add To Cart').click

      find('.cart-info').click
      sleep 3
      find('button', :text => 'Checkout').click
      find('[value="Save and Continue"]').click
      find('[value="Save and Continue"]').click
      find('[value="Save and Continue"]').click
      find('[value="Place Order"]').click

      puts "*******************"
      puts find('.alert-notice').text
      first('.alert-notice').text.should == 'Your order has been processed successfully'
      find('a', :text => 'Home').click
      puts i
    end
  end

  it 'buying mug Spree Mug' do

    find('.list-group-item', :text => 'Mugs').click
    find('[title="Spree Mug"]').click
    find('[id="quantity"]').set('12')
    find('button', :text => 'Add To Cart').click

    find('.cart-info').click
    sleep 3
    find('button', :text => 'Checkout').click
    find('[value="Save and Continue"]').click
    find('[value="Save and Continue"]').click
    find('[value="Save and Continue"]').click
    find('[value="Place Order"]').click

    puts "*******************"
    puts find('.alert-notice').text
    first('.alert-notice').text.should == 'Your order has been processed successfully'
    find('a', :text => 'Home').click
  end
  end
end
