require 'nokogiri'
require 'open-uri'
require 'pry'

class Parser

  def initialize(url, filename)
    @url = url
    @filename = filename
  end

  def run
    # TODO validate url here

    related_paths = CategoryPage.new(@url).product_paths
    ProductPage.new(@url, related_path).product_data
  end

end

class CategoryPage

  def initialize(url)
    @url = url
  end

  # parse **related** product paths
  def product_paths
    page = Nokogiri::HTML(open(@url))
    page.xpath("//div[contains(@class, 'floating-content-box')]//div[contains(@class, 'gridbox')]/a/@href")
  end
end

class ProductPage

  def initialize(url, paths)
    @url = url
    @paths = paths
  end

  def product_data
  end

end
