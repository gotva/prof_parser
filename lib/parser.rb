require 'nokogiri'
require 'open-uri'
require 'uri'
require 'pry'
require 'csv'

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

class CategoryPage

  def initialize(url)
    @url = url
  end

  # parse **related** product paths
  def product_paths
    page = Nokogiri::HTML(open(@url))
    page.xpath("//div[contains(@class, 'floating-content-box')]
                //div[contains(@class, 'gridbox')]
                /a/@href").map(&:value)
  end
end

class ProductPage

  def initialize(url, paths)
    @url = url
    @paths = paths

    @domain = URI.parse(@url).scheme + '://' + URI.parse(@url).host
  end

  def product_data
    @paths.map do |path|
      read_product_page(path)
    end.flatten
  end

  private

  def read_product_page(path)
    @current_path = path
    page = Nokogiri::HTML(open(@domain + path))

    name = product_name(page)
    image = product_image(page)
    items = product_items(page)

    items.each do |item|
      item[:name] = "#{name} - #{item[:pack]}"
      item[:image] = URI.parse(@url).scheme + ':' + image
    end

    items
  end

  def product_name(page)
    page.xpath("//div[contains(@class, 'content-box')]/div/div/h1").text
  end

  def product_image(page)
    page.xpath("//div[contains(@class, 'content-box')]
                /div[contains(@class, 'internal-row')][1]
                /div[contains(@class, 'gridbox')][1]
                //img/@src")[0].value
  end

  def product_items(page)
    line_xpath = "//div[contains(@class, 'content-box')]
                  /ul[@id='product_listing']
                  /li[contains(@class, 'product')]"

    packs = page.xpath(line_xpath + "//div[@class='title']/text()[normalize-space()]").map { |pack| pack.text.strip }
    prices = page.xpath(line_xpath + "//div[@class='ours']/span/text()").map { |price| price.text }
    deliveries = page.xpath(line_xpath + "/div/strong/text()").map { |delivery| delivery.text.strip }
    sku = page.xpath(line_xpath + "//strong[@itemprop='sku']/text()").map { |item| item.text }

    check_count_of_items(packs, prices, deliveries, sku)

    packs.size.times.inject([]) do |result, i|
      result <<
        {
          pack: packs[i],
          price: prices[i],
          delivery: deliveries[i],
          sku: sku[i]
        }
      result
    end
  end

  def check_count_of_items(*args)
    sizes = args.map(&:size)
    if sizes.min != sizes.max
      puts "Something is wrong during parsing page #{@domain + path}"
    end
  end

end
