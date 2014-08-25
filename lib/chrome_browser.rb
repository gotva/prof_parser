require 'singleton'
require 'watir-webdriver'

class ChromeBrowser
  include Singleton
  attr_reader :browser

  def initialize
    @browser ||= Watir::Browser.new :chrome
  end

  def close
    @browser.close
  end

end
