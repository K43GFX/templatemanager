require 'test_helper'

class ClonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @clone = clones(:one)
  end

  test "should get index" do
    get clones_url
    assert_response :success
  end

  test "should get new" do
    get new_clone_url
    assert_response :success
  end

  test "should create clone" do
    assert_difference('Clone.count') do
      post clones_url, params: { clone: {  } }
    end

    assert_redirected_to clone_url(Clone.last)
  end

  test "should show clone" do
    get clone_url(@clone)
    assert_response :success
  end

  test "should get edit" do
    get edit_clone_url(@clone)
    assert_response :success
  end

  test "should update clone" do
    patch clone_url(@clone), params: { clone: {  } }
    assert_redirected_to clone_url(@clone)
  end

  test "should destroy clone" do
    assert_difference('Clone.count', -1) do
      delete clone_url(@clone)
    end

    assert_redirected_to clones_url
  end
end
