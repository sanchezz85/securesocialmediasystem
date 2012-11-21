require 'test_helper'

class GuestbookentriesControllerTest < ActionController::TestCase
  setup do
    @guestbookentry = guestbookentries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:guestbookentries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create guestbookentry" do
    assert_difference('Guestbookentry.count') do
      post :create, guestbookentry: @guestbookentry.attributes
    end

    assert_redirected_to guestbookentry_path(assigns(:guestbookentry))
  end

  test "should show guestbookentry" do
    get :show, id: @guestbookentry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @guestbookentry
    assert_response :success
  end

  test "should update guestbookentry" do
    put :update, id: @guestbookentry, guestbookentry: @guestbookentry.attributes
    assert_redirected_to guestbookentry_path(assigns(:guestbookentry))
  end

  test "should destroy guestbookentry" do
    assert_difference('Guestbookentry.count', -1) do
      delete :destroy, id: @guestbookentry
    end

    assert_redirected_to guestbookentries_path
  end
end
