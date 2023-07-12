require 'csv'
require 'date'

# CSVファイルを読み込む
csv = CSV.read('sales.csv', headers: true)

# 読み込んだ元データの件数
puts "----読み込んだデータの件数-------"
puts "Total rows: #{csv.size}"
puts "-----------------------------"


# ＜問題1の解答＞

# 個数、売上の0の有無チェック
csv.each do |row|
  if row['sales'] == '0'
    puts 'sales = O presence!'
    return
  elsif row['quantity'] == '0'
    puts 'quantity = O presence!'
    return
  end
end

# データクリーニング
cleaned_csv = csv.reject do |row|
  row.size > 6 || # 6列以上ある
  row['sales_date'].nil? || row['sales_date'].strip.empty? || # sales_dateが空
  row['sales'].to_i.zero? || # salesが空白（0は存在しない）
  row['quantity'].to_i.zero? || # quantityが空白（0は存在しない）
  row['product_name'].nil? || row['product_name'].strip.empty? || # product_nameが空
  row['store'].nil? || row['store'].strip.empty? # storeが空
end

# 日付形式の統一
cleaned_csv.each do |row|
  row['sales_date'] = Date.strptime(row['sales_date'], '%Y年%m月%d日') rescue Date.parse(row['sales_date'])
end

# # クリーニングデータの件数
puts "---クリーニング後データの件数-------"
puts "Total rows: #{cleaned_csv.size}"
puts "-------------------------------"

# # クリーニング前後のデータ数比率
remaining_rate = cleaned_csv.size.to_f / csv.size
puts "-------残件数率--------------------"
puts "Decrease rate: #{remaining_rate}"
puts "-------------------------------"

# ＜問題2の解答＞
puts '▫️商品の種類と単価'
# 商品の種類と単価の計算
total_prices = Hash.new(0)
counts = Hash.new(0)

cleaned_csv.each do |row|
  product_name = row['product_name']
  price = row['sales'].to_i / row['quantity'].to_i

  total_prices[product_name] += price
  counts[product_name] += 1
end

# 平均単価の計算
average_prices = {}
total_prices.each do |product_name, total_price|
  average_prices[product_name] = total_price / counts[product_name]
  puts "商品の種類： #{product_name},価格：#{average_prices[product_name]}"
end
puts "-------------------------------"


# ＜問題3の解答＞
# 商品別の売上金額集計
sales_by_product = Hash.new(0)
cleaned_csv.each do |row|
  sales_by_product[row['product_name']] += row['sales'].to_i
end

puts '▫️商品の種類ごとの売上金額の集計（クリーニング後のデータ）'
sales_by_product.each do |product, sales|
  puts "Product: #{product}, Sales: #{sales}"
end

puts '▫️商品の種類ごとの売上金額の集計（元データの推定値）'
sales_by_product.each do |product, sales|
  puts "Product: #{product}, Sales: #{sales / remaining_rate}"
end
puts "-------------------------------"

# ＜問題4の解答＞
# 年月別、店舗別、商品別の売上集計
sales_by_month_store_product = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = Hash.new(0) } }
cleaned_csv.each do |row|
  month = row['sales_date'].strftime('%Y-%m')
  store = row['store']
  product = row['product_name']
  sales_by_month_store_product[month][store][product] += row['sales'].to_i
end

# 東京の売上が最も大きかった月の最も売り上げた商品を選ぶ
tokyo_sales_by_month = sales_by_month_store_product.map { |month, stores| [month, stores['東京'].values.sum] }.to_h
max_sales_month = tokyo_sales_by_month.max_by { |_, sales| sales }[0]
max_sales_product_in_month = sales_by_month_store_product[max_sales_month]['東京'].max_by { |_, sales| sales }[0]

puts "東京の最も売上が大きかった月: #{max_sales_month}"
puts "東京の最も売上が大きかった月の最も売り上げた商品名: #{max_sales_product_in_month}"
puts "-------------------------------"



