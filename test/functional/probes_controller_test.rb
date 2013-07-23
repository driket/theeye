require 'test_helper'

class ProbesControllerTest < ActionController::TestCase
  setup do
    @probe = probes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:probes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create probe" do
    assert_difference('Probe.count') do
      post :create, probe: @probe.attributes
    end

    assert_redirected_to probe_path(assigns(:probe))
  end

  test "should show probe" do
    get :show, id: @probe
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @probe
    assert_response :success
  end

  test "should update probe" do
    put :update, id: @probe, probe: @probe.attributes
    assert_redirected_to probe_path(assigns(:probe))
  end

  test "should destroy probe" do
    assert_difference('Probe.count', -1) do
      delete :destroy, id: @probe
    end

    assert_redirected_to probes_path
  end
end
