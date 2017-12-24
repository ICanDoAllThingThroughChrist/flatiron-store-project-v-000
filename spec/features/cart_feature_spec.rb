describe 'Feature Test: Cart', :type => :feature do

  describe "Checking out" do

    context "logged in" do
      before(:each) do
        @user = User.first
        #Spec uses the Test Database, and seeds it from seed.rb from db/seeds.rb
        @user.current_cart = @user.carts.create
        #https://www.sitepoint.com/brush-up-your-knowledge-of-rails-associations/
        ## Note: a @person variable will have been created in the controller (e.g. @person = Person.new)
        #http://guides.rubyonrails.org/action_view_overview.html
        @current_cart = @user.current_cart
        #https://apidock.com/rails/ActiveRecord/Associations/ClassMethods/belongs_to
        #A Post class declares belongs_to :author, which will add:
        #belongs_to :author, class_name: "Person", foreign_key: "author_id"
        #A Cart class declares belongs_to :current_cart "in the User Class", which will add:
        #belongs_to :current_cart, class_name: "Cart", foreign_key: "current_cart_id"
        #add current_cart_id in the migration file, by 1st: rake db:drop, 2nd: rake db:migrate
        #https://youtu.be/x_qQCnYPyBk?t=945
        @first_item = Item.first
        @first_item.line_items.create(quantity: 1, cart: @user.current_cart)
        #https://ducktypelabs.com/how-a-has_many-through-association-works-in-practice/
        @second_item = Item.second
        @second_line_item = @second_item.line_items.create(quantity: 1, cart: @user.current_cart)
        login_as(@user, scope: :user)
      end

     it "Lists all items in the cart" do
       visit cart_path(@user.current_cart)
        # cart GET    /carts/:id(.:format)      carts#show
        # PATCH  /carts/:id(.:format)           carts#update
        # PUT    /carts/:id(.:format)           carts#update
        # DELETE /carts/:id(.:format)           carts#destroy
       expect(page).to have_content(@first_item.title)
       expect(page).to have_content(@second_item.title)
     end

     it "Has a Checkout Button" do
       visit cart_path(@user.current_cart)
       expect(page).to have_button("Checkout")
     end

     it "redirects to cart show page on Checkout" do
       visit cart_path(@user.current_cart)
       click_button("Checkout")

       expect(page.current_path).to eq(cart_path(@current_cart))
       expect(page).to_not have_button("Checkout")
     end

     it "subtracts quantity from inventory" do
       @second_line_item.quantity = 3
       @second_line_item.save
       first_item_inventory_before = @first_item.inventory
       second_item_inventory_before = @second_item.inventory
       visit cart_path(@user.current_cart)
       click_button("Checkout")

       @second_item.reload
       @first_item.reload
       expect(@first_item.inventory).to eq(first_item_inventory_before-1)
       expect(@second_item.inventory).to eq(second_item_inventory_before-3)
     end

     it "sets current_cart to nil on checkout" do
       visit cart_path(@user.current_cart)
       click_button("Checkout")

       @user.reload
       expect(@user.current_cart).to be_nil
     end
    end
  end
  describe "Adding To Cart" do

    context "logged in" do
      before(:each) do
        @user = User.first
        login_as(@user, scope: :user)
      end

      it "Doesn't show Cart link when there is no current cart" do
        cart = @user.carts.create(status: "submitted")
        first_item = Item.first
        first_item.line_items.create(quantity: 1, cart: cart)
        @user.current_cart = nil
        visit store_path
        expect(page).to_not have_link("Cart")
      end

      it "Does show Cart link when there is a current cart" do
        @user.current_cart = @user.carts.create(status: "submitted")
        first_item = Item.first
        first_item.line_items.create(quantity: 1, cart: @user.current_cart)
        @user.save
        visit store_path
        expect(page).to have_link("Cart", href: cart_path(@user.current_cart))
      end

      it "Creates a current_cart when adding first item " do
        first_item = Item.first
        @user.current_cart = nil
        @user.save
        visit store_path
        within("form[action='#{line_items_path(item_id: first_item)}']") do
          click_button("Add to Cart")
        end
        @user.reload
        expect(@user.current_cart).to_not be_nil
      end

      it "Uses the same cart when adding a second item" do
        first_item = Item.first
        second_item = Item.second
        @user.current_cart = nil
        @user.save
        visit store_path
        within("form[action='#{line_items_path(item_id: first_item)}']") do
          click_button("Add to Cart")
        end

        @user.reload
        current_cart = @user.current_cart

        visit store_path
        within("form[action='#{line_items_path(item_id: second_item)}']") do
          click_button("Add to Cart")
        end

        @user.reload
        expect(@user.current_cart.id).to eq(current_cart.id)
      end

      it "Adds the item to the cart" do
        first_item = Item.first
        @user.current_cart = nil
        @user.save
        visit store_path
        within("form[action='#{line_items_path(item_id: first_item)}']") do
          click_button("Add to Cart")
        end
        @user.reload
        expect(@user.current_cart.items).to include(first_item)
      end

      it "Shows you the cart after you hit add to cart" do
        first_item = Item.first
        visit store_path
        within("form[action='#{line_items_path(item_id: first_item)}']") do
          click_button("Add to Cart")
        end
        @user.reload
        expect(page.current_path).to eq(cart_path(@user.current_cart))
      end

      it "Updates quantity when selecting the same item twice" do
        first_item = Item.first
        2.times do
          visit store_path
          within("form[action='#{line_items_path(item_id: first_item)}']") do
            click_button("Add to Cart")
          end
        end
        @user.reload
        expect(@user.current_cart.items.count).to eq(1)
        expect(@user.current_cart.line_items.count).to eq(1)
        expect(@user.current_cart.line_items.first.quantity).to eq(2)
        expect(page).to have_content("Quantity: 2")
        total = first_item.price * 2
        expect(page).to have_content("$#{total.to_f/100}")
      end

    end
  end
end
