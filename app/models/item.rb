class Item < ActiveRecord::Base
  has_many :line_items
  belongs_to :category

  def self.available_items
    count = []
    Item.all.each do |item|
      if item.inventory > 0
        count << item
      end
    end
    count
  end

  def remove(amount)
    update(inventory: inventory - amount)
  end
end
