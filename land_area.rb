require 'httparty'
require 'mysql2'
require 'nokogiri'

client = Mysql2::Client.new(
    :host => 'localhost',
    :username => 'root',
    :password => 'root',
    :database => 'bee_core_project',
)
(2 .. 22).each do |n|
    src = 'https://talis.moa.gov.tw/ALIES/farmlandsurveyreport/111/sheet' + '%03d' % [n] + '.htm'
    res = HTTParty.get(src)
    if res.code == 200
        content = Nokogiri::HTML4(res.body)
        city = content.css('.xl127').text[0 .. 2]
        total_area_string = content.css('.xl127').text.match(/\((.+) ha\)/)[1]
        total_area = total_area_string.gsub!(',', '').to_i
        legal_area_string = content.css('.xl130').text.match(/\（ (.+) ha\）/)[1]
        legal_area_string = legal_area_string[0 .. legal_area_string.index(' ')]
        legal_area = legal_area_string.gsub!(',', '').to_i
        producted_area = content.css('.xl70')[9].text.gsub(/[[:space:]]/, '').gsub(',', '')
        producted_area = 0 if producted_area == '-'
        producted_area = producted_area.to_i
        managed_area = content.css('.xl70')[10].text.gsub(/[[:space:]]/, '').gsub(',', '').to_i
        sql_query = "INSERT INTO land_area_usage
        (city,
        producted_area,
        managed_area,
        legal_area,
        total_area)
        VALUES
        ('#{city}', #{producted_area}, #{managed_area}, #{legal_area}, #{total_area});"
        client.query(sql_query)
    end
end
client.close