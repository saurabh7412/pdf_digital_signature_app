require "test_helper"

class PdfsControllerTest < ActionDispatch::IntegrationTest
  test "should get sign" do
    get pdfs_sign_url
    assert_response :success
  end
end
