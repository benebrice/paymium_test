require 'json'
require 'byebug'
require 'awesome_print'

def order_filter(orders, direction = 'buy')
  orders.select{|o| o['direction'] == direction}
end

def matcher(val1, val2)
  val1.to_i == val2.to_i
end

def change_user(user_id, btc_amount, price, direction = 'buy')
  user = @users.select{|u| matcher(u['id'], user_id) }.first
  if direction == 'buy'
    user['btc_balance'] += btc_amount
    user['eur_balance'] -= price
  else
    user['btc_balance'] -= btc_amount
    user['eur_balance'] += price
  end
  @final_users.push(user)
end

def execute_queued_orders(queued_order1, queued_order2)
  change_user(queued_order1['user_id'], queued_order1['btc_amount'], queued_order1['price'], queued_order1['direction'])
  change_user(queued_order2['user_id'], queued_order2['btc_amount'], queued_order2['price'], queued_order2['direction'])
  queued_order1['state'] = 'executed'
  queued_order2['state'] = 'executed'
  @orders.push(queued_order1, queued_order2)
  @buying_orders = remove_queued_order(@buying_orders, queued_order1['id'])
  @selling_orders = remove_queued_order(@selling_orders, queued_order2['id'])
end

def remove_queued_order(orders, order_id)
  orders.select{|order| !matcher(order['id'], order_id) }
end

def record_orders(users, buying_orders, selling_orders, orders)
  output_file = File.open('output2.json', 'w')
  hash = {
    users: users,
    queued_orders: buying_orders + selling_orders,
    orders: orders
  }
  output_file.write(hash.to_json)
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
      execute_queued_orders(buying_order, selling_order)
    end
  end
end

record_orders(@users, @buying_orders, @selling_orders, @orders)
