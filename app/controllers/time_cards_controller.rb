class TimeCardsController < ApplicationController
  def index
    @time_cards = TimeCard.all
  end
  
  def scrape
    require "playwright"
    TimeCard.delete_all
    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      playwright.chromium.launch(headless: false) do |browser|
        # サイトへアクセス
        page = browser.new_page
        page.goto(ENV["SCRAPE_URL"])
        page.wait_for_timeout(1000)
        page.wait_for_selector("#time_cards")
        
        # テーブル情報を取得
        table = page.query_selector_all("tbody")
        rows = page.query_selector_all('table tr')
        
        # テーブルの行を取得
        formatted_rows = []
        rows.each do |row|
          cells = row.query_selector_all("td")
          row_data = cells.map { |cell| cell.inner_text.strip }
          formatted_rows << row_data unless row_data.all?(&:empty?)
        end
        
        formatted_rows.each do |row|
          # データの整形
          date = Date.strptime(row[0].gsub(/\(.+\)/, ""), "%m月%d日")
          start_time_scheduled, end_time_scheduled = row[1] == "-" ? [nil, nil] : row[1].split("〜").map(&:strip).map { |time| Time.parse(time) }
          start_time_actual, end_time_actual = row[2] == "-" ? [nil, nil] : row[2].split("〜").map(&:strip).map { |time| Time.parse(time) }
          holiday_status = row[4]
          application_status = row[10]
          
          TimeCard.create(
            date: date,
            start_time_scheduled: start_time_scheduled&.strftime('%H:%M'),
            end_time_scheduled: end_time_scheduled&.strftime('%H:%M'),
            start_time_actual: start_time_actual&.strftime('%H:%M'),
            end_time_actual: end_time_actual&.strftime('%H:%M'),
            holiday_status: holiday_status,
            application_status: application_status
          )
        end
      end
    end
    redirect_to root_path, notice: "スクレイピングが成功しました"
  end

  def edit
  end
end
