require "test_helper"

class QuizControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get quiz_index_url
    assert_response :success
  end

  test "should get show" do
    get quiz_show_url
    assert_response :success
  end

  test "should get new" do
    get quiz_new_url
    assert_response :success
  end

  test "should get create" do
    get quiz_create_url
    assert_response :success
  end

  test "should get edit" do
    get quiz_edit_url
    assert_response :success
  end

  test "should get update" do
    get quiz_update_url
    assert_response :success
  end

  test "should get destroy" do
    get quiz_destroy_url
    assert_response :success
  end
end
