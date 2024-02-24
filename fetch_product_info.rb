require 'net/http'
require 'json'
require 'mysql2'
require './lib/database'

uri = URI('https://data.moa.gov.tw/Service/OpenData/TransService.aspx?UnitId=ABTXmIWuosiO')
response = Net::HTTP.get(uri)
json_data = JSON.parse(response)
client = Mysql2::Client.new(
    :host => 'localhost',
    :username => 'root',
    :password => 'root',
    :database => 'bee_core_project',
)
json_data.each do |record|
    sql_query = "INSERT INTO agri_product_info
    (year,
    crop_name,
    output,
    output_value)
    VALUES
    (#{record['year']},
    \"#{record['crop_name'].include?('-') ? record['crop_name'][record['crop_name'].index('-') + 1 .. -1] : record['crop_name']}\",
    #{record['output'].to_i},
    #{record['output_value'].to_i});"
    client.query(sql_query)
end
client.close()