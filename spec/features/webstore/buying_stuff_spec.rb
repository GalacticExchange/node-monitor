RSpec.describe "Webstore", :type => :request do

  # gex_env=main browser=chrome rspec spec/features/webstore/buying_stuff_spec.rb

  1.upto(20) do |i|
    describe 'buying stuff' do

      before :all do

        Dir.chdir("/work/tests")

      end

      after :each do

      end


      it 'buying stuff loop' do
        puts i

        puts "Buying shirts"
        stdout, stdeerr, status = Open3.capture3("gex_env=main browser=chrome rspec spec/features/webstore/buying_shirts_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/shop.log")
        puts "slepping...1"


        puts "Buying mugs"
        stdout, stdeerr, status = Open3.capture3("gex_env=main browser=chrome rspec spec/features/webstore/buying_mugs_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/shop.log")
        puts "sleeping...2"

        puts "Buying bags"
        stdout, stdeerr, status = Open3.capture3("gex_env=main browser=chrome rspec spec/features/webstore/buying_bags_spec.rb >> ~/log/\"$(date +\"%d.%m.%y\")\"/shop.log")
        puts "slepping...3"



      end
    end
  end
end