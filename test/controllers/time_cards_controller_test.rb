require "test_helper"

class TimeCardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get time_cards_index_url
    assert_response :success
  end

  test "should get edit" do
    get time_cards_edit_url
    assert_response :success
  end
end
