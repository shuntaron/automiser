class TimeCardsController < ApplicationController
  def index
    @time_cards = TimeCard.all
  end

  def edit
  end
end
