require "test_helper"

class ContagemPessoasControllerTest < ActionDispatch::IntegrationTest

  test "should return the number of persons" do
    get contagem_pessoas_url, as: :json
    assert_response :success
    assert_equal(3, response.parsed_body)
  end
end
