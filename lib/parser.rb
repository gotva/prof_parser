require 'nokogiri'
require 'open-uri'

class Parser

  def initialize(url, filename)
    @url = url
    @filename = filename
  end

  def run
    p "started with url: #{@url}"
    p "output to: #{@filename}"
  end

end

# page = Nokogiri::HTML(open("http://en.wikipedia.org/"))
# puts page.class   # => Nokogiri::HTML::Document
