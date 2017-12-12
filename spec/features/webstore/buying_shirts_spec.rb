RSpec.describe "Webstore", :type => :request do

  # gex_env=main browser=chrome rspec spec/features/webstore/buying_shirts_spec.rb

  describe 'buying shirts' do


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


    it 'buying shirt Ruby on Rails Baseball Jersey' do
      for i in 0..3 do
        find('.list-group-item', :text => 'Clothing').click
        page.all('[title="Ruby on Rails Baseball Jersey"]')[0].click
        find('button', :text => 'Add To Cart').click
        page.all('.line_item_quantity')[0].set('2')
        find('button', :text => 'Update').click

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


    it 'buying shirt Ruby on Rails Jr. Spaghetti' do

      for i in 0..10 do
        find('.list-group-item', :text => 'Clothing').click
        page.all('[title="Ruby on Rails Jr. Spaghetti"]')[0].click
        find('button', :text => 'Add To Cart').click
        page.all('.line_item_quantity')[0].set('9')
        find('button', :text => 'Update').click

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


=begin
    it 'buying shirt Ruby on Rails Ringer T-Shirt' do

      find('.list-group-item', :text => 'Clothing').click
      page.all('[title="Ruby on Rails Ringer T-Shirt"]')[0].click
      find('button', :text => 'Add To Cart').click
      page.all('.line_item_quantity')[0].set('3')
      find('button', :text => 'Update').click

      find('.cart-info').click
      find('button', :text => 'Checkout').click
      find('[value="Save and Continue"]').click
      find('[value="Save and Continue"]').click
      find('[value="Save and Continue"]').click
      find('[value="Place Order"]').click

      puts "*******************"
      puts find('.alert-notice').text
      first('.alert-notice').text.should == 'Your order has been processed successfully'
      find('a', :text => 'Home'). click
    end
=end

    it 'buying shirt Spree Jr. Spaghetti' do
      for i in 0..15 do

        find('.list-group-item', :text => 'Clothing').click
        page.all('[title="Spree Jr. Spaghetti"]')[0].click
        find('button', :text => 'Add To Cart').click
        page.all('.line_item_quantity')[0].set('12')
        find('button', :text => 'Update').click

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

    it 'buying shirt Apache Baseball Jersey' do
      for i in 0..5 do

        find('.list-group-item', :text => 'Clothing').click
        page.all('[title="Apache Baseball Jersey"]')[0].click
        find('button', :text => 'Add To Cart').click
        page.all('.line_item_quantity')[0].set('15')
        find('button', :text => 'Update').click

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

    it 'buying shirt Ruby Baseball Jersey' do

      for i in 0..8 do
        find('.list-group-item', :text => 'Clothing').click
        page.all('[title="Ruby Baseball Jersey"]')[0].click
        find('button', :text => 'Add To Cart').click
        page.all('.line_item_quantity')[0].set('3')
        find('button', :text => 'Update').click

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

    it 'buying shirt Spree Baseball Jersey' do
      for i in 0..2 do

        find('.list-group-item', :text => 'Clothing').click
        page.all('[title="Spree Baseball Jersey"]')[0].click
        find('button', :text => 'Add To Cart').click
        page.all('.line_item_quantity')[0].set('8')
        find('button', :text => 'Update').click

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

    it 'buying shirt Spree Ringer T-Shirt' do
      for i in 0..12 do

        find('.list-group-item', :text => 'Clothing').click
        page.all('[title="Spree Ringer T-Shirt"]')[0].click
        find('button', :text => 'Add To Cart').click
        page.all('.line_item_quantity')[0].set('7')
        find('button', :text => 'Update').click

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
