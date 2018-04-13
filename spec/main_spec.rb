require_relative '../main.rb'

describe 'Main instance' do
  before do
    @main = Main.new
  end

  it 'has users' do
    expect(@main.users).not_to be_empty
    expect(@main.users.count).to eq(2)
  end

  it 'has queued_orders' do
    expect(@main.queued_orders).not_to be_empty
    expect(@main.queued_orders.count).to eq(2)
  end

  it 'has not any final users' do
    expect(@main.final_users).to be_empty
  end

  it 'has buying_orders' do
    expect(@main.buying_orders).not_to be_empty
    expect(@main.buying_orders.count).to eq(1)
  end

  it 'has selling_orders' do
    expect(@main.selling_orders).not_to be_empty
    expect(@main.selling_orders.count).to eq(1)
  end

  it 'has not any orders' do
    expect(@main.orders).to be_empty
  end
end

describe 'Main class methods' do
  it 'matches 2 identical values (String or Integer)' do
    expect(Main.matcher(1, 2)).to be false
    expect(Main.matcher(1, "1")).to be true
    expect(Main.matcher(1, 1)).to be true
  end

  it 'filters array by `direction` attribute (buy/sell)' do
    orders = [stringify({'direction': 'buy'}), stringify({'direction': 'sell'})]
    expect(Main.order_filter(orders).count).to eq(1)
    expect(Main.order_filter(orders, 'buy').count).to eq(1)
    expect(Main.order_filter(orders, 'sell').count).to eq(1)
  end

  def stringify(hash)
    Hash[hash.collect{|k,v| [k.to_s, v]}]
  end

end
