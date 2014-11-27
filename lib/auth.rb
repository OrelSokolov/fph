require 'yaml'
require 'cgi'
require 'uri'
require 'colorize'
require 'watir-webdriver'
require 'headless'

ROOT = File.join(File.dirname(__FILE__), '../')

config = YAML.load_file "#{ROOT}/config/app.yml"
CONFIG = config

URL = %Q|  https://oauth.vk.com/authorize?
           client_id=#{config['APP_ID']}&
           scope=#{config['PERMISSIONS']}&
           redirect_uri=#{config['REDIRECT_URI']}&
           display=#{config['DISPLAY']}&
           v=#{config['API_VERSION']}&
           response_type=token
          |.strip.delete ' '

class VkAuth
  def initialize
    @auth_config = YAML.load_file "#{ROOT}/config/auth.yml"
  end

  def token
    get_token
  end

  private
    def get_token
      headless = Headless.new
      headless.start
      browser = Watir::Browser.new
      browser.goto URL
      browser.input
      browser.text_field(:name => 'email').set @auth_config['login']
      browser.text_field(:name => 'pass').set @auth_config['pass']
      browser.input(:type => 'submit').click
      unless browser.url.include? CONFIG['REDIRECT_URI']
        browser.input(:type => 'submit').click # Allow
      end
      params = CGI.parse(URI.parse(browser.url).fragment)
      browser.close
      headless.destroy
      puts 'Auth succesful'.green if params["access_token"]
      params["access_token"].first
    end
end

