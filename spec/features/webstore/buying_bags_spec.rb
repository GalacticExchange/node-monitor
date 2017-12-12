RSpec.describe "Webstore", :type => :request do

  # gex_env=main rspec spec/features/webstore/buying_bags_spec.rb

  describe 'buying bags' do

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


    it 'buying bag Ruby on Rails Bag' do

      for i in 0..7 do
        find('.list-group-item', :text => 'Bags').click
        find('[title="Ruby on Rails Bag"]').click
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


    it 'buying bag Ruby on Rails Tote' do
      for i in 0..2 do
        find('.list-group-item', :text => 'Bags').click
        find('[title="Ruby on Rails Tote"]').click
        find('[id="quantity"]').set('3')
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

    it 'buying bag Spree Bag' do

      for i in 0..3 do
        find('.list-group-item', :text => 'Bags').click
        find('[title="Spree Bag"]').click
        find('[id="quantity"]').set('3')
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

    it 'buying bag Spree Tote' do

      for i in 0..10 do
        find('.list-group-item', :text => 'Bags').click
        find('[title="Spree Tote"]').click
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

  end
end
