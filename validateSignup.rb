require "json"
require "selenium-webdriver"
require "rspec"
require "yaml"
include RSpec::Expectations

describe "EmailSignup" do

  before(:each) do
	puts 'selenium test running before'
	config = YAML.load_file("config_smiley.yml")
	
    @driver = Selenium::WebDriver.for :firefox
    @base_url = config['member']['base_url']
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
	@name = config['signup']['validate_first'] + "." +config['signup']['validate_last']
	@email = @name + "@yopmail.com"
	@pass = config['member']['pass']
	@zip = config['signup']['zip_CA']
	@first_name = config['signup']['first_name_CA']
	@last_name = config['signup']['last_name_CA']
  end
  
  after(:each) do
    #@driver.quit
    @verification_errors.should == []
  end
  
  it "test_signup" do
    puts 'selenium test running'
	
    @driver.get(@base_url + "/home")
    @driver.find_element(:css, "button.login-switch-button").click
	sleep(2)
	@driver.find_element(:xpath, "(//input[@id='member_email'])[2]").click
    @driver.find_element(:xpath, "(//input[@id='member_email'])[2]").clear
    @driver.find_element(:xpath, "(//input[@id='member_email'])[2]").send_keys @email
	sleep(2)
    @driver.find_element(:xpath, "(//input[@id='member_password'])[2]").clear
    @driver.find_element(:xpath, "(//input[@id='member_password'])[2]").send_keys @pass
    sleep(2)
	#@driver.find_element(:css, "label.control-checkbox").click
	sleep(1)
    @driver.find_element(:css, "span").click
    @driver.find_element(:xpath, "(//input[@name='commit'])[2]").click
	sleep(2)
	@driver.get("http://yopmail.com");
	sleep(4)
	@driver.find_element(:id, "login").click
    @driver.find_element(:id, "login").clear
    @driver.find_element(:id, "login").send_keys @name
    @driver.find_element(:css, "input.sbut").click
	sleep(1)
	puts 'switching to internal iframe'
	@driver.switch_to.frame('ifmail')
	sleep(1)
    
    @href = @driver.find_element(:link, "CONFIRM ACCOUNT").attribute('href')
	puts 'activation link: '+@href
	@driver.get(@href)
	
   
    @driver.find_element(:id, "member_first_name").clear
    @driver.find_element(:id, "member_first_name").send_keys @validate_first
=begin
    @driver.find_element(:id, "member_last_name").clear
    @driver.find_element(:id, "member_last_name").send_keys @validate_last
	@driver.manage.window.maximize
	sleep(2)
    @driver.find_element(:id, "member_zip_code").clear
	#@driver.find_element(:id, "member_country").click
	sleep(2)
	#Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "member_country")).select_by(:text, "Canada")
	#drop = Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "member_country"))
	#drop1 = drop.select_by(:text, "Canada")
	dropdown_list = @driver.find_element(:id, 'member_country')
	#Get all the options from the dropdown
	options = dropdown_list.find_elements(tag_name: 'option')
	#Find the dropdown value by text
	options.each { |option| option.click if option.text == "Canada" }
	sleep(1)
	
	#abc = @driver.find_element(:xpath, "//select[@id='member_country']").click
	#abc.find_element(:css, "option[text()='Canada']").click
	#sleep(2)
	#//select[@id='member_country']/option[1]
    @driver.find_element(:id, "member_zip_code").send_keys @zip
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "date_month")).select_by(:text, "February")
	sleep(1)
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "date_day")).select_by(:text, "7")
	sleep(1)
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "date_year")).select_by(:text, "1991")
	sleep(3)
    @driver.find_element(:xpath, "(//label[@class='control-radio'])[1]").click
	sleep(2)
=end
    @driver.find_element(:name, "commit").click
	@driver.save_screenshot "Screenshots/validate.png"
	@driver.find_element(:css, "a.btn.btn-color.btn-lg").click
	puts "The test was successfull"
	
	sleep(2)
  end
  
  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
  def verify(&blk)
    yield
  rescue ExpectationNotMetError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
