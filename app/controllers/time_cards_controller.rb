class TimeCardsController < ApplicationController
  def index
    @time_cards = TimeCard.all
  end
  
  def scrape
    require "playwright"
    TimeCard.delete_all
    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      playwright.chromium.launch(headless: false) do |browser|
        # 勤怠情報画面へアクセス
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
    redirect_to root_path, notice: "勤怠予実取得が成功しました"
  end

  def edit
  end
  
  def bulk_edit
    @time_cards = TimeCard.all
  end
  
  def bulk_update
    ids = time_cards_params.keys
    attributes_array = time_cards_params.values
    @time_cards = TimeCard.update(ids, attributes_array)
    @time_cards.reject! { |p| p.errors.empty? }
    if @time_cards.empty?
      redirect_to bulk_edit_time_cards_path, notice: "勤怠手動更新が成功しました"
    else
      render "bulk_edit", alert: "勤怠手動更新が失敗しました"
    end
  end
  
  def sync_data
    require "playwright"
    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      playwright.chromium.launch(headless: false) do |browser|
        page = browser.new_page
        # 勤怠編集画面へアクセス
        page.goto(ENV["EDIT_TIMECARD_URL"])
        page.wait_for_timeout(1000)
        page.wait_for_selector("#time_cards")
        
        time_cards = TimeCard.all
        time_cards.each do |time_card|
          if time_card.start_time_scheduled.present? && time_card.end_time_scheduled.present?
            page.fill("tr[data-date='#{time_card.date.strftime('%Y-%m-%d')}'] > td:nth-child(3) > input[type=time]:nth-child(1)", time_card.start_time_scheduled.strftime('%H:%M'))
            page.fill("tr[data-date='#{time_card.date.strftime('%Y-%m-%d')}'] > td:nth-child(3) > input[type=time]:nth-child(2)", time_card.end_time_scheduled.strftime('%H:%M'))
          end
        end
        page.click("input[type='submit']")
        page.wait_for_timeout(1000)
        page.wait_for_selector("#time_cards")
        
        # 勤怠情報画面へアクセス
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
        
        TimeCard.delete_all
        
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
    redirect_to root_path, notice: "勤怠自動登録が成功しました"
  end
  
  def bulk_delete
    TimeCard.delete_all
    redirect_to root_path, notice: "勤怠情報を削除しました"
  end
  
  private
  
  def time_cards_params
    params.require(:time_card).permit(time_cards: [:start_time_actual, :end_time_actual, :break_start_time, :break_end_time])[:time_cards]
  end
  
end
