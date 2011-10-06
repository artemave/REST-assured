# details are here http://carol-nichols.com/2011/07/seleniumwebdrivererrorunhandlederror-ns_error_illegal_value/
class Capybara::Selenium::Driver
  def find(selector)
    browser.find_elements(:xpath, selector).map { |node| Capybara::Selenium::Node.new(self, node) }
  rescue Selenium::WebDriver::Error::InvalidSelectorError => e
    e.message =~ /nsIDOMXPathEvaluator.createNSResolver/ ? retry : raise
  end
end
