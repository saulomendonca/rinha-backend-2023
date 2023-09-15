require "test_helper"

class PessoasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @person = {
      apelido: 'Ju',
      nascimento: '1985-05-15',
      nome: 'Juliana',
      stack: ["Ruby", "Javascript"]
    }
  end

  #List
  test "get index with empty search should return success" do
    get pessoas_url({ t: 'paralepipedo' }), as: :json
    assert_response :success
    assert_equal([], response.parsed_body)
  end

  test "should find 3 result with search Mar" do
    get pessoas_url({ t: 'Mar' }), as: :json
    assert_response :success
    assert_equal(3, response.parsed_body.size)
  end

  test "should find 2 result with search Mar" do
    get pessoas_url({ t: 'ub' }), as: :json
    assert_response :success
    assert_equal(2, response.parsed_body.size)
  end

  test "should bring a maximun of 50 results" do
    55.times { |n| Pessoa.create(apelido: "Ju#{n}", nascimento: '1985-05-15', nome: 'Juliana') }
    get pessoas_url({ t: 'Ju' }), as: :json
    assert_response :success
    assert_equal(50, response.parsed_body.size)
  end

  test "should return bad request if term is not specified" do
    get pessoas_url(), as: :json
    assert_response :bad_request
  end

  # Show
  test "should show person" do
    get pessoa_url(pessoas(:one)), as: :json
    assert_response :success
  end

  test "should show person with all attributes" do
    get pessoa_url(pessoas(:one)), as: :json
    assert_response :success

    person = pessoas(:one)
    assert_equal(person[:id], response.parsed_body["id"])
    assert_equal(person[:apelido], response.parsed_body["apelido"])
    assert_equal(person[:nascimento].to_s, response.parsed_body["nascimento"])
    assert_equal(person[:nome], response.parsed_body["nome"])
    assert_equal(person[:stack], response.parsed_body["stack"])
  end

  test "should return not_found for a non valid id" do
    get pessoa_url('AAA'), as: :json
    assert_response :not_found
  end

  #Create

  test "should create person" do
    assert_difference("Pessoa.count") do
      post pessoas_url, params: @person, as: :json
    end

    assert_response :created
  end

  test "should set all data" do
    post pessoas_url, params: @person, as: :json

    assert_response :created
    assert_equal(@person[:apelido], response.parsed_body["apelido"])
    assert_equal(@person[:nascimento], response.parsed_body["nascimento"])
    assert_equal(@person[:nome], response.parsed_body["nome"])
    assert_equal(@person[:stack], response.parsed_body["stack"])
  end

  test "should create person and return location" do
    post pessoas_url, params: @person, as: :json

    assert_response :created
    assert_equal("/pessoas/#{Pessoa.find_by(apelido: @person[:apelido]).id}", response.header['Location'])
  end

  test "should not create a person with a not string nickname" do
    @person['apelido'] = 1
    post pessoas_url, params: @person, as: :json

    assert_response :bad_request
  end

  test "should not create a person with a repeated nickname" do
    @person[:apelido] = pessoas(:one).apelido
    post pessoas_url, params: @person, as: :json

    assert_response :unprocessable_entity
  end

  test "should not create a person without a nickname" do
    @person['apelido'] = nil
    post pessoas_url, params: @person, as: :json

    assert_response :unprocessable_entity
  end

  test "should not create a person with a nickname with 1 caracters" do
    @person['apelido'] = 'a'
    post pessoas_url, params: @person, as: :json

    assert_response :created
  end

  test "should not create a person with a nickname with 32 caracters" do
    @person['apelido'] = 'a' * 32
    post pessoas_url, params: @person, as: :json

    assert_response :created
  end

  test "should not create a person without a nickname bigger than 32 caracters" do
    @person['apelido'] = 'a' * 33
    post pessoas_url, params: @person, as: :json

    assert_response :unprocessable_entity
  end

  test "should not create a person with a not string name" do
    @person['nome'] = 1
    post pessoas_url, params: @person, as: :json

    assert_response :bad_request
  end


  test "should not create a person without a name" do
    @person['nome'] = nil
    post pessoas_url, params: @person, as: :json

    assert_response :unprocessable_entity
  end

  test "should not create a person with a name with 1 caracters" do
    @person['nome'] = 'a'
    post pessoas_url, params: @person, as: :json

    assert_response :created
  end

  test "should not create a person with a name with 100 caracters" do
    @person['nome'] = 'a' * 100
    post pessoas_url, params: @person, as: :json

    assert_response :created
  end

  test "should not create a person without a name bigger than 100 caracters" do
    @person['nome'] = 'a' * 101
    post pessoas_url, params: @person, as: :json

    assert_response :unprocessable_entity
  end

  test "should not create a person with a not string birthday" do
    @person['nascimento'] = 1
    post pessoas_url, params: @person, as: :json

    assert_response :bad_request
  end

  test "should not create a person without a birthday" do
    @person['nascimento'] = nil
    post pessoas_url, params: @person, as: :json

    assert_response :unprocessable_entity
  end

  test "should not create a person with an invalid birthday" do
    @person['nascimento'] = 'aa'
    post pessoas_url, params: @person, as: :json

    assert_response :bad_request
  end

  test "should not create a person with a not string stack" do
    @person[:stack] = [1]
    post pessoas_url, params: @person, as: :json

    assert_response :bad_request
  end

  test "should create person without stack" do
    @person[:stack] = nil
    assert_difference("Pessoa.count") do
      post pessoas_url, params: @person, as: :json
    end

    assert_response :created

    assert_nil(response.parsed_body["stack"])
  end

  test "should not create person with stack with empty string" do
    @person[:stack] = [""]
    post pessoas_url, params: @person, as: :json

    assert_response :unprocessable_entity
  end

  test "should create person with stack with 32 caracter" do
    @person[:stack] = [@person['apelido'] = 'a' * 32]
    post pessoas_url, params: @person, as: :json

    assert_response :created
  end

  test "should not create person without stack greater than 32 caracter" do
    @person[:stack] = ['a' * 33]
    post pessoas_url, params: @person, as: :json

    assert_response :unprocessable_entity
  end

  #update

  test "should update person" do
    name = 'Alterado'
    @person[:nome] = name
    patch pessoa_url(pessoas(:one)), params: @person, as: :json
    assert_response :success
    assert_equal(name, response.parsed_body["nome"])
  end

  #destroy

  test "should destroy person" do
    assert_difference("Pessoa.count", -1) do
      delete pessoa_url(pessoas(:one)), as: :json
    end

    assert_response :no_content
  end
end
