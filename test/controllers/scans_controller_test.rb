require 'test_helper'

class ScansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @scan = scans(:one)
  end

  test "should get index" do
    get scans_url
    assert_response :success
  end

  test "should get new" do
    get new_scan_url
    assert_response :success
  end

  test "should create scan" do
    assert_difference('Scan.count') do
      post scans_url, params: { scan: { session: @scan.session, subject: @scan.subject } }
    end

    assert_redirected_to scan_url(Scan.last)
  end

  test "should show scan" do
    get scan_url(@scan)
    assert_response :success
  end

  test "should get edit" do
    get edit_scan_url(@scan)
    assert_response :success
  end

  test "should update scan" do
    patch scan_url(@scan), params: { scan: { session: @scan.session, subject: @scan.subject } }
    assert_redirected_to scan_url(@scan)
  end

  test "should destroy scan" do
    assert_difference('Scan.count', -1) do
      delete scan_url(@scan)
    end

    assert_redirected_to scans_url
  end
end
