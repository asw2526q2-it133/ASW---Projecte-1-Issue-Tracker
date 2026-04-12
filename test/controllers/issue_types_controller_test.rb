require "test_helper"

class IssueTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @issue_type = issue_types(:one)
  end

  test "should get index" do
    get issue_types_url
    assert_response :success
  end

  test "should get new" do
    get new_issue_type_url
    assert_response :success
  end

  test "should create issue_type" do
    assert_difference("IssueType.count") do
      post issue_types_url, params: { issue_type: { color: @issue_type.color, name: @issue_type.name } }
    end

    assert_redirected_to issue_type_url(IssueType.last)
  end

  test "should show issue_type" do
    get issue_type_url(@issue_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_issue_type_url(@issue_type)
    assert_response :success
  end

  test "should update issue_type" do
    patch issue_type_url(@issue_type), params: { issue_type: { color: @issue_type.color, name: @issue_type.name } }
    assert_redirected_to issue_type_url(@issue_type)
  end

  test "should destroy issue_type" do
    assert_difference("IssueType.count", -1) do
      delete issue_type_url(@issue_type)
    end

    assert_redirected_to issue_types_url
  end
end
