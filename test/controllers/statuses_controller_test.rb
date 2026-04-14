=begin
require "test_helper"

class StatusesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status = statuses(:one)
  end

  test "should get index" do
    get statuses_url
    assert_response :success
  end

  test "should get new" do
    get new_status_url
    assert_response :success
  end

  test "should create status" do
    assert_difference("Status.count") do
      post statuses_url, params: { status: { color: "Random", name: "Random" } }
    end

    assert_redirected_to statuses_url
  end

  test "should show status" do
    get status_url(@status)
    assert_response :success
  end

  test "should get edit" do
    get edit_status_url(@status)
    assert_response :success
  end

  test "should update status" do
    patch status_url(@status), params: { status: { color: "Random", name: "Random" } }
    assert_redirected_to statuses_url
  end

  test "should destroy status" do
    assert_difference("Status.count", -1) do
      delete status_url(@status)
    end

    assert_redirected_to statuses_url
  end
end
=end
