require 'geocoder'
require 'json'
require 'open-uri'
require 'csv'

class Scraper

  @@access_token = "AAAAAAITEghMBAK7KpykAWj4KZCe3ZCCZBDAiZAmjg4uL19BOjXUEZBZB6O2OcmiaVjDxyBFuLuowLisYGlrTX20b534xP1M2xfTSZC6miK3lQZDZD"

  def initialize
    puts "Enter the location, e.g. Cebu City"
    @location = gets.chomp
    puts "Query e.g. Restaurant, Coffee Shop, Bar."
    @query = gets.chomp
    puts "Facebook [1]Pages or [2]Places?"
    @type = gets.chomp
    puts "How many pages of data? Enter a number"
    @pages = gets.chomp

    start
  end

  def start
    data = []
    next_page = ""
    query = ""
    if @type.downcase == "1"
      query = "#{@location.downcase.gsub(' ', '+')}+#{@query.downcase.gsub(' ', '+')}"
      next_page = "https://graph.facebook.com/search?q=#{query}&type=page"
    elsif @type.downcase == "2"
      geocode = Geocoder.search(@location)
      query = @query.downcase.gsub(' ', '+')
      next_page = "https://graph.facebook.com/search?q=#{query}&type=place&center=#{geocode[0].latitude},#{geocode[0].longitude}&access_token=#{@@access_token}"
    end
    
    (1..@pages.to_i).each do |p|
      begin
        data << JSON.parse(open(URI.encode(next_page)).read)
        next_page = data.last['paging']['next']
      rescue
        nil
      end
    end

    CSV.open('output.csv', 'wb') do |f|
      data.each do |d|
        d['data'].each do |s|
          page_info = JSON.parse(open(URI.encode("https://graph.facebook.com/#{s['id']}")).read)
          f <<  ["#{s['name']}", "http://facebook.com/#{s['id']}", "#{page_info['website']}"]
        end
      end
    end

  end

end

Scraper.new
