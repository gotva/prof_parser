# class fetches product urls (related urls)
# accept page url
# return array of related urls
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
