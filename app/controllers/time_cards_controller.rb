class TimeCardsController < ApplicationController
  def index
    @time_cards = TimeCard.all
  end
  
  def scrape
    require "playwright"
    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      playwright.chromium.launch(headless: false) do |browser|
        page = browser.new_page
        page.goto(ENV["SCRAPE_URL"])
        page.wait_for_timeout(1000)
        page.wait_for_selector("#time_cards")
      end
    end
    redirect_to root_path, notice: "スクレイピングが成功しました"
  end

  def edit
  end
end
