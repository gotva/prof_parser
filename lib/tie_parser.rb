require 'nokogiri'
require 'csv'
require 'pry'

require_relative 'chrome_browser'

class TieParser

  def initialize(filename)
    @filename = filename

    @url = 'http://tires.bjs.com/'
    @browser = ChromeBrowser.instance.browser
  end

  def run
    start = Time.now

    # Watir cheat list (obsolete but useful)
    # http://pettichord.com/watirtutorial/docs/watir_cheat_sheet/WTR/Cheat%20Sheet.html
    @browser.goto(@url)

    search_by_size
    data = parse_resulted_page
    save_data_to_file(data)

    puts "Process is completed (~#{(Time.now - start).to_i} sec.)"
    puts "See results in #{@filename}"
  ensure
    p "browser is closed"
    @browser.close
  end

  private

  def search_by_size
    @browser.element(xpath: "//ul[@id='resultsTabs']/li[@id='tab_2']/a").click

    wait_and_set_value("TWAR:widths", "265")
    wait_and_set_value("TWAR:aspects", "65")
    wait_and_set_value("TWAR:rims", "17")
    wait_and_set_value("DLR:state", "CT")
    wait_and_set_value("DLR:city", "Brookfield")

    wait_and_click("//p[@class='search_button']/input[@id='DLR:findLocations']")
    wait_and_click("//p[@class='find_tires']/img[@id='findTiresTopStatic']")
    wait_and_click("//div[@class='page_content']/a[@class='clickToContinue']")
    wait_and_click("//div[@class='pagination']/ul/li[@class='viewall']/a[@id='tlForm:j_id251']")

    element = @browser.element(xpath: "//div[@class='pagination']/ul/li[@class='viewall']/a[@id='tlForm:j_id251']")
    Watir::Wait.until(5) { !element.exists? }
  end

  def wait_and_set_value(name, value)
    element = @browser.select_list(:name, name)
    Watir::Wait.until(5) { element.enabled? }
    element.select(value)
  end

  def wait_and_click(xpath)
    element = @browser.element(xpath: xpath)
    Watir::Wait.until(5) { element.exists? && element.visible? }
    element.click
  end

  def parse_resulted_page
    page = Nokogiri::HTML(@browser.html)

    names = page.xpath("//table[@class='results']
                        //td[@class='col2']
                        /h4").map(&:text)

    images = page.xpath("//table[@class='results']
                          //div[@class='photo_comparison']
                          /div[contains(@class, 'photo_comparison_img')]
                          /img/@src").map(&:value)

    prices = page.xpath("//table[@class='results']
                          //td[@class='col3']
                          //span[@class='tireprice']").map { |el| el.text.strip }

    check_count_of_items(images, names, prices)

    names.size.times.inject([]) do |result, i|
      result <<
        {
          name: names[i],
          price: prices[i],
          image: images[i]
        }
      result
    end
  end

  def check_count_of_items(*args)
    sizes = args.map(&:size)
    if sizes.min != sizes.max
      puts "Something is wrong during parsing page"
    end
  end

  def save_data_to_file(data)
    CSV.open(@filename, 'wb') do |csv|
      csv << %w[Name Image Price]

      data.each do |line|
        csv <<
        [
          line[:name],
          line[:image],
          line[:price]
        ]
      end
    end
  end

end
