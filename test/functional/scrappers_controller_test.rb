require 'test_helper'

class ScrappersControllerTest < ActionController::TestCase
  test "should get show_latest_books" do
    get :show_latest_books
    assert_response :success
  end

end
