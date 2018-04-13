require 'json'

class Main
  # Easier to test
  attr_reader :users, :final_users, :queued_orders, :buying_orders, :selling_orders, :orders
  def initialize
    data = JSON.parse(File.open('data.json').read)

    @users = data['users']
    @final_users = []
    @queued_orders = data['queued_orders']

    @buying_orders = Main.order_filter(queued_orders)
    @selling_orders = Main.order_filter(queued_orders, 'sell')

    @orders = []
  end

  def execute
    @buying_orders.each do |buying_order|
      @selling_orders.each do |selling_order|
        if Main.matcher(buying_order['price'], selling_order['price'])
          execute_queued_orders(buying_order, selling_order)
        end
      end
    end

    Main.record_orders(@users, @buying_orders, @selling_orders, @orders)
  end

  def execute_queued_orders(queued_order1, queued_order2)
    update_data(queued_order1)
    update_data(queued_order2)
    @buying_orders = Main.remove_queued_order(@buying_orders, queued_order1['id'])
    @selling_orders = Main.remove_queued_order(@selling_orders, queued_order2['id'])
  end

  def update_data(queued_order)
    user_id, btc_amount, price, direction = queued_order['user_id'], queued_order['btc_amount'], queued_order['price'], queued_order['direction']
    queued_order['state'] = 'executed'
    store_user(user_id, btc_amount, price, direction)
    @orders.push(queued_order)
  end

  def store_user(user_id, btc_amount, price, direction)
    user = @users.select{|u| Main.matcher(u['id'], user_id) }.first
    if direction == 'buy'
      user['btc_balance'] += btc_amount
      user['eur_balance'] -= btc_amount * price
    else
      user['btc_balance'] -= btc_amount
      user['eur_balance'] += btc_amount * price
    end
    @final_users.push(user)
  end

  class << self
    def order_filter(orders, direction = 'buy')
      orders.select{|o| o['direction'] == direction}
    end

    def matcher(val1, val2)
      val1.to_i == val2.to_i
    end

    def remove_queued_order(orders, order_id)
      orders.select{|order| !matcher(order['id'], order_id) }
    end

    def record_orders(users, buying_orders, selling_orders, orders, file_name = 'output2.json')
      output_file = File.open(file_name, 'w')
      hash = {
        users: users,
        queued_orders: buying_orders + selling_orders,
        orders: orders
      }
      output_file.write(hash.to_json)
    end
  end
end


# Not run during tests
if $PROGRAM_NAME == __FILE__
  main = Main.new
  main.execute
end

