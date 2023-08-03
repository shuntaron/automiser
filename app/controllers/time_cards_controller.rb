class TimeCardsController < ApplicationController
  def index
    @time_cards = TimeCard.all
  end
  
  def scrape
    redirect_to root_path, notice: "スクレイピングが成功しました"
  end

  def edit
  end
end
