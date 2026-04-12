require "test_helper"

class SeveritiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @severity = severities(:one)
  end

  test "should get index" do
    get severities_url
    assert_response :success
  end

  test "should get new" do
    get new_severity_url
    assert_response :success
  end

  test "should create severity" do
    assert_difference("Severity.count") do
      post severities_url, params: { severity: { color: @severity.color, name: @severity.name } }
    end

    assert_redirected_to severity_url(Severity.last)
  end

  test "should show severity" do
    get severity_url(@severity)
    assert_response :success
  end

  test "should get edit" do
    get edit_severity_url(@severity)
    assert_response :success
  end

  test "should update severity" do
    patch severity_url(@severity), params: { severity: { color: @severity.color, name: @severity.name } }
    assert_redirected_to severity_url(@severity)
  end

  test "should destroy severity" do
    assert_difference("Severity.count", -1) do
      delete severity_url(@severity)
    end

    assert_redirected_to severities_url
  end
end
