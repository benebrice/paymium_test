require 'json'
require 'byebug'
require 'awesome_print'

def order_filter(orders, direction = 'buy')
  orders.select{|o| o['direction'] == direction}
end

def matcher(val1, val2)
  val1.to_i == val2.to_i
end


data = JSON.parse(File.open('data.json').read)

@users = data['users']
@final_users = []
queued_orders = data['queued_orders']

@buying_orders = order_filter(queued_orders)
@selling_orders = order_filter(queued_orders, 'sell')

@orders = []
@buying_orders.each do |buying_order|
  @selling_orders.each do |selling_order|
    if matcher(buying_order['price'], selling_order['price'])
      #execute_queued_orders(buying_order, selling_order)
      ap 'match'
    end
  end
end