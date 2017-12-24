class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  def index
    @items = Item.available_items
    @categories = Category.all
  end

  private
  def set_item
    @items = Item.find(params[:id])
  end
end
