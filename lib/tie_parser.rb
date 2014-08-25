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
    # Watir cheat list (obsolete but useful)
    # http://pettichord.com/watirtutorial/docs/watir_cheat_sheet/WTR/Cheat%20Sheet.html
    @browser.goto(@url)

    search_by_size

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
    wait_and_click("//div[@class='pagination']/li[@class='viewall']/a[@id='tlForm:j_id251']")

    binding.pry
  end

  def wait_and_set_value(name, value)
    element = @browser.select_list(:name, name)
    Watir::Wait.until(5) { element.enabled? }
    element.select(value)
  end

  def wait_and_click(xpath)
    element = @browser.element(xpath: xpath)
    Watir::Wait.until(5) { element.exists? && element.enabled? }
    element.click
  end

end
