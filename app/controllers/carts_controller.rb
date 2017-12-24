
class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :edit, :update, :destroy]

    def show
        @items = current_user.current_cart.items
    end

    def checkout
      remove_item
      current_user.remove_cart
      redirect_to cart_path(current_user)
    end

    private
    def set_cart
      @carts = Cart.find(params[:id])
    end

    def remove_item
      current_user.current_cart.line_items.each do |item|
        @items = Item.find(item.item_id)
        @items.inventory -= item.quantity
        @items.save
      end
    end
end
