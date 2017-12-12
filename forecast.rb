#encoding: utf-8
#класс прогноза
require 'net/http'
require 'uri'
require 'rexml/document'


class Forecast


  def self.cities
    {'Москва' => 'https://xml.meteoservice.ru/export/gismeteo/point/37.xml',
     'Санкт-Петербург' => 'https://xml.meteoservice.ru/export/gismeteo/point/69.xml',
     'Таганрог' => 'https://xml.meteoservice.ru/export/gismeteo/point/134.xml',
     'Ростов-на-дону'=> 'https://xml.meteoservice.ru/export/gismeteo/point/135.xml'
    } # вставить ссылки на xml прогнозов по городам
  end

  def self.create(city, forecast)
    return new(city, forecast)
  end

  def self.get_forecast(city)
    weather_parsed = {}


    uri = URI.parse(cities[city]) #загрузка прогноза погоды для города

    responce = Net::HTTP.get_response(uri)
    doc = REXML::Document.new(responce.body)


    weather = [] #Создание массивов с прогнозами на сутки
    i = 0
    4.times do
      weather << doc.root.elements['REPORT/TOWN'].elements.to_a[i]
      i += 1
    end


    weather.each do |value|
      city_name = URI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])
      day = value.to_s
      weather_parsed[city_name + " " + day] = Forecast.create(city_name, value)
    end

    return weather_parsed

  end

  def initialize(city, forecast)
    @city_name = city
    load_forecast(forecast)
  end


  def show_forecast
    puts
    puts
    puts "#{@city_name} #{@date} #{calc_time}:"
    puts '-------------------------'
    puts "#{@clouds}"
    if @min_temp == @max_temp
      puts "Температура воздуха в течении дня - #{@min_temp}."
    else
      puts "Минимальная температура воздуха #{@min_temp}, максимально воздух прогреется до #{@max_temp}."
    end
    puts "Атмосферное давление  - #{@pressure} мм ртутного столба. Ветер - #{@max_wind} м/с."
  end


  def load_forecast(forecast)
    @min_temp = forecast.elements['TEMPERATURE'].attributes['min']
    @max_temp = forecast.elements['TEMPERATURE'].attributes['max']
    @pressure = forecast.elements['PRESSURE'].attributes['min'].to_s + ".." + forecast.elements['PRESSURE'].attributes['min'].to_s
    @max_wind = forecast.elements['WIND'].attributes['max']
    cloudiness_index = forecast.elements['PHENOMENA'].attributes['cloudiness'].to_i
    cloudiness = {0 => 'Ясно', 1 => 'Малооблачно', 2 => 'Облачно', 3 => 'Пасмурно'}
    @clouds = cloudiness[cloudiness_index]
    @date = forecast.attributes['day'].to_s + "." +forecast.attributes['month'].to_s + "." + forecast.attributes['year'].to_s
    @time = forecast.attributes['hour'] + ":00"
  end


  def calc_time
    case @time
      when '03:00'
        return 'ночью'
      when '09:00'
        return 'утром'
      when '15:00'
        return 'днем'
      when '21:00'
        return 'вечером'
    end
  end

end

