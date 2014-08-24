require 'nokogiri'
require 'open-uri'
require 'uri'
# require 'pry'
require 'csv'

require_relative 'category_page'
require_relative 'product_page'

class Parser

  def initialize(url, filename)
    @url = url
    @filename = filename
  end

  def run
    # TODO validate url here
    start = Time.now
    related_paths = CategoryPage.new(@url).product_paths
    data = ProductPage.new(@url, related_paths).product_data
    save_data_to_file(data)

    puts "Process is completed (~#{(Time.now - start).to_i} sec.)"
    puts "See results in #{@filename}"
  end

  private

  def save_data_to_file(data)
    CSV.open(@filename, 'wb') do |csv|
      csv << %w[Name Price Image Delivery SKU]

      data.each do |line|
        csv <<
        [
          line[:name],
          line[:price],
          line[:image],
          line[:delivery],
          line[:sku]
        ]
      end
    end
  end

end
