### ＜課題内容＞

https://drive.google.com/file/d/1D13bXxD7vALnK0KHhFF7rGo1EKIL5y14/view?usp=drive_link

## ＜進め方概要＞

- 課題内容から(sales.csv)のコピーを作成
- (sales.csv)のコピーをRubyで読み込む
- 問に合わせたRubyプログラムを実行し、目的の結果を取得する

### ＜作成したソース＞

コマンドを実行していただくことで下記の結果が得られます。

```c
$ruby data_processing.rb
```

プログラム実行結果結果

```bnf

----読み込んだデータの件数-------
Total rows: 1000000
-----------------------------
---クリーニング後データの件数-------
Total rows: 390348
-------------------------------
-------残件数率--------------------
Decrease rate: 0.390348
-------------------------------
▫️商品の種類と単価
商品の種類： ウルトラ オプション,価格：1500
商品の種類： ノーマル オプション,価格：500
商品の種類： スーパー オプション,価格：1000
商品の種類： ノーマル プラン,価格：10000
商品の種類： ウルトラ プラン,価格：30000
商品の種類： スーパー プラン,価格：20000
-------------------------------
▫️商品の種類ごとの売上金額の集計（クリーニング後のデータ）
Product: ウルトラ オプション, Sales: 4855471500
Product: ノーマル オプション, Sales: 1622080000
Product: スーパー オプション, Sales: 3260563000
Product: ノーマル プラン, Sales: 32452360000
Product: ウルトラ プラン, Sales: 97044900000
Product: スーパー プラン, Sales: 64964100000
▫️商品の種類ごとの売上金額の集計（元データの推定値）
Product: ウルトラ オプション, Sales: 12438827661.471304
Product: ノーマル オプション, Sales: 4155471527.9699144
Product: スーパー オプション, Sales: 8352964534.2105
Product: ノーマル プラン, Sales: 83136995706.39532
Product: ウルトラ プラン, Sales: 248611239201.9429
Product: スーパー プラン, Sales: 166426112084.60144
-------------------------------
東京の最も売上が大きかった月: 2022-05
東京の最も売上が大きかった月の最も売り上げた商品名: ウルトラ プラン
-------------------------------
```

### ＜問いに対する回答＞

# 問1

データを集計できる形に修正してください。その際にどのような手順を踏んだかを説明してく
ださい。

### 回答

データの修正・集計のために、

下記条件に合致する行をcsvから取り除く処理（データクリーニング）をRubyで実行しました。

- 1行につき６列以上のデータを保有
- salesが空白（0は元から存在しない）
- quantityが空白（0は元から存在しない）
- product_nameが空（文字列の前後の空白も含む）
- storeが空（文字列の前後の空白も含む）

その後、日付の形式を統一。

↓実行コード↓

```ruby
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
```

※処理実行前後のレコード数

読み込んだ元データの件数：1000000

クリーニング後データの件数：390348

※残件数率：39.0348％

# 問２

商品の種類と単価をデータから推測してください。いずれも店舗、年によって変化がないもの
とします。

## 回答

▫️商品の種類と単価
商品の種類： ウルトラ オプション,価格：1500
商品の種類： ノーマル オプション,価格：500
商品の種類： スーパー オプション,価格：1000
商品の種類： ノーマル プラン,価格：10000
商品の種類： ウルトラ プラン,価格：30000
商品の種類： スーパー プラン,価格：20000

手順は、

1. 各レコードでprice( sales ÷ quantity )を定義
2. クリーニング後の全レコードからproduct_nameとpriceを組み合わせた配列を作成
3. product_nameの文字列が一致している要素のsalesの合計値を算出
4. product_nameの件数で、salesの合計値を守り戻した平均値を算出

↓実行コード↓

```ruby
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
```

# 問3

商品の種類ごとの売上金額を集計してください。

### 回答

▫️商品の種類ごとの売上金額の集計（クリーニング後のデータ）
Product: ウルトラ オプション, Sales: 4855471500
Product: ノーマル オプション, Sales: 1622080000
Product: スーパー オプション, Sales: 3260563000
Product: ノーマル プラン, Sales: 32452360000
Product: ウルトラ プラン, Sales: 97044900000
Product: スーパー プラン, Sales: 64964100000
▫️商品の種類ごとの売上金額の集計（元データの推定値）
Product: ウルトラ オプション, Sales: 12438827661.471304
Product: ノーマル オプション, Sales: 4155471527.9699144
Product: スーパー オプション, Sales: 8352964534.2105
Product: ノーマル プラン, Sales: 83136995706.39532
Product: ウルトラ プラン, Sales: 248611239201.9429
Product: スーパー プラン, Sales: 166426112084.60144

※　クリーニング後のデータの集計をもとに、元データの集計を推定値として算出してます

手順は単純で、

1. クリーニング後のデータ全レコードから、product_name毎のsalesの合算値を算出
2. １で求めた値を、残件数率：39.0348％（問１で算出）で割り戻す

↓実行コード↓

```ruby
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
```

# 問4

年月別に集計し、東京の売上が一番大きかった月の最も売り上げた商品を答えてください。

### 回答

ウルトラ プラン（2022年05月）

手順としては、

1. クリニーング後のデータをsales_date（%Y-%m）、store、product_nameでグループ化
2. グループ化した単位で、salesの合計値を算出
3. ２からstoresが東京であるデータのみ抽出
4. ３で作成したデータで比較（salesの合計値が最大であるものをピックアップ）

↓実行コード↓
