require 'nokogiri'
require 'capybara'
require 'open-uri'
require 'pry'

# start 1:30pm, Feb 27
# stop 2:30pm, Feb 27
# start 3:30pm, Feb 27
# stop 6:00pm, Feb 27

def find_and_return_cur_day_user_count(browser)
  fm_user_ids = []
  facepiles = browser.all 'div.facepile a'
  facepiles.each do |face|
    fm_user_ids << /\d+/.match(face['onclick'])[0]
  end
  return fm_user_ids.count
end

def scrape_fitmob_users
  url = 'https://www.fitmob.com'
  cp_login_email = 'rebeccamhathaway@gmail.com'
  cp_login_pw = "classpass"
  Capybara.current_driver = :selenium
  Capybara.app_host = url
  browser = Capybara.current_session
  browser.visit('/login')
  browser.fill_in("email", :with=> cp_login_email )
  browser.fill_in("pwd", :with=> cp_login_pw )
  browser.click_button("login_email")
  days = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday']
  browser.find("#caldays_monday").click
  sleep 20
  fm_date_hash = {}

  days.each do |day|
    now = Time.now
    present_day = now.day.to_i
    present_month = now.month.to_i
    current_year = now.year.to_i
    current_day = /\d+/.match(browser.find("#caldays_#{day}").text)[0].to_i
    if current_day > present_day
      current_month = present_month - 1
    else
      current_month = present_month
    end

    current_date = "#{current_month}-#{current_day}-#{current_year}"
    browser.find("#caldays_#{day}").click
    sleep 5
    user_count = find_and_return_cur_day_user_count(browser)
    fm_date_hash[current_date] = user_count
    
  end
  
  tot_fm_users ||= 0
  fm_date_hash.values.each { |a| tot_fm_users+=a }

  puts fm_date_hash
  puts "Total Current Fitmob Users: #{tot_fm_users}"

end
scrape_fitmob_users


# ===================
# GOALS
# 1. Scrape the user_ids for today for all classes in scrape_fitmob_users
#    - Data to collect:
#      - Class ID (key to hash)
#         - User_ids (value as an array)
# 2. Use Mechanize to login and navigate to the correct pages
# 3. Create a chron_job to run daily at 8am to update information
# 4. Rake task for manual updates


# NOTES
#  browser.all 'div.facepile'  # for class_id (#id)