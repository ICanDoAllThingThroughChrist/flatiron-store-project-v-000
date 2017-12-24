# == Schema Information
#
# Table name: carts
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  status     :string           default("not submitted")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Cart < ActiveRecord::Base
  has_many :line_items, dependent: :destroy
  has_many :items, through: :line_items
  belongs_to :user

  def add_item(item_id)
    line_item = self.line_items.find_by(item_id: item_id)
    if line_item.blank?
        item = Item.find_by(id: item_id)
        item.line_items.build(quantity: 1, cart: self)
      else line_item
        line_item.quantity += 1
        line_item
      end
  end

  def total
    total = 0
    self.line_items.each do |line_item|
      total += line_item.item.price * line_item.quantity
    end
    return total
  end
end
