require 'test_helper'

class FriendlistentriesControllerTest < ActionController::TestCase
  setup do
    @friendlistentry = friendlistentries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:friendlistentries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create friendlistentry" do
    assert_difference('Friendlistentry.count') do
      post :create, friendlistentry: @friendlistentry.attributes
    end

    assert_redirected_to friendlistentry_path(assigns(:friendlistentry))
  end

  test "should show friendlistentry" do
    get :show, id: @friendlistentry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @friendlistentry
    assert_response :success
  end

  test "should update friendlistentry" do
    put :update, id: @friendlistentry, friendlistentry: @friendlistentry.attributes
    assert_redirected_to friendlistentry_path(assigns(:friendlistentry))
  end

  test "should destroy friendlistentry" do
    assert_difference('Friendlistentry.count', -1) do
      delete :destroy, id: @friendlistentry
    end

    assert_redirected_to friendlistentries_path
  end
end
