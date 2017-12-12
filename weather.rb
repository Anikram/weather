#encoding: utf-8
# weather ver. 1 - by Anikram 08.12.2017
# Данные для программы взяты с http:/meteoservice.ru/content/export.xml

#require 'net/http'
#require 'uri'
#require 'rexml/document'
require_relative 'forecast.rb'


cities = Forecast.cities.keys


puts "Выбери город из списка:"
i = 1
cities.each_entry  do |k|
  puts " #{i}. #{k};"
  i += 1
end

user_input = STDIN.gets.chomp.to_s
cities.each_entry do |k|
  if user_input == k

    weather_parsed = Forecast.get_forecast(user_input)

    weather_parsed.each do |index,value|
      value.show_forecast
    end
  end
end














