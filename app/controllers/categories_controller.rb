
class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

   def index
     @categories = Category.all
   end

   def show
     @items = @category.items
   end

   private
   def set_category
     @category = Category.find_by(params[:id])

   end
end
