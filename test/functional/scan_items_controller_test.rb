require 'test_helper'

class ScanItemsControllerTest < ActionController::TestCase
  test "should get incoming" do
    get :incoming
    assert_response :success
  end

  test "should get warehouse_in" do
    get :warehouse_in
    assert_response :success
  end

  test "should get warehouse_out" do
    get :warehouse_out
    assert_response :success
  end

end
