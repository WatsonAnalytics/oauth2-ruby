require 'test_helper'

class WaLoginControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get redirect" do
    get :redirect
    assert_response :success
  end

end
