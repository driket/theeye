require 'test_helper'

class ThresholdsControllerTest < ActionController::TestCase
  setup do
    @threshold = thresholds(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:thresholds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create threshold" do
    assert_difference('Threshold.count') do
      post :create, threshold: @threshold.attributes
    end

    assert_redirected_to threshold_path(assigns(:threshold))
  end

  test "should show threshold" do
    get :show, id: @threshold
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @threshold
    assert_response :success
  end

  test "should update threshold" do
    put :update, id: @threshold, threshold: @threshold.attributes
    assert_redirected_to threshold_path(assigns(:threshold))
  end

  test "should destroy threshold" do
    assert_difference('Threshold.count', -1) do
      delete :destroy, id: @threshold
    end

    assert_redirected_to thresholds_path
  end
end
