class PessoasController < ApplicationController
  before_action :set_pessoa, only: %i[ show update destroy ]
  MAX_RESULTS = 50
  CACHE_EXPIRES = 10.minutes

  # GET /pessoas
  def index
    if params[:t].present?
      term = "%#{params[:t]}%"
      @pessoas = Pessoa
        .where(
          "searchable ilike :term",
          term: term
        )
        .limit(MAX_RESULTS)

      render json: @pessoas
    else
      head :bad_request
    end
  end

  # GET /pessoas/1
  def show
    if @pessoa
      render json: @pessoa.attributes.except('searchable')
    else
      head :not_found
    end
  end

  def create
    return unless validate_params

    if Rails.cache.fetch("a/#{pessoa_params[:apelido]}")
      head :unprocessable_entity
      return
    end

    @pessoa = Pessoa.new(pessoa_params)

    if @pessoa.valid?
      Rails.cache.write("a/#{@pessoa.apelido}", '', expires_in: CACHE_EXPIRES)
      Rails.cache.write("p/#{@pessoa.id}", @pessoa, expires_in: CACHE_EXPIRES)

      pessoa_hash = pessoa_params.to_h
      pessoa_hash[:id] = @pessoa.id
      Pessoas::CreatePessoaAsync.new.save(pessoa_hash)
      render json: pessoa_hash, status: :created, location: "/pessoas/#{@pessoa.id}"
    else
      head :unprocessable_entity
    end
  end

  # PATCH/PUT /pessoas/1
  def update
    if @pessoa.update(pessoa_params)
      render json: @pessoa
    else
      head :unprocessable_entity
    end
  end

  # DELETE /pessoas/1
  def destroy
    @pessoa.destroy
  end

  private
    def set_pessoa
      @pessoa = Rails.cache.fetch("p/#{params[:id]}", expires_in: CACHE_EXPIRES) do
        Pessoa.find_by(id: params[:id])
      end
    end

    def pessoa_params
      params.require(:pessoa).permit(:apelido, :nome, :nascimento, :stack => [])
    end

    def validate_params
      if pessoa_params[:apelido] && !pessoa_params[:apelido].is_a?(String)
        head :bad_request
        return
      end

      if pessoa_params[:nome] && !pessoa_params[:nome].is_a?(String)
        head :bad_request
        return
      end

      date_format = /\A(19|20)[0-9]{2}-(0[1-9]|1[12])-([012][0-9]|3[01])\Z/
      if pessoa_params[:nascimento] && (!pessoa_params[:nascimento].is_a?(String) || !pessoa_params[:nascimento]&.match?(date_format))
        head :bad_request
        return
      end

      if pessoa_params[:stack] && (!pessoa_params[:stack].is_a?(Array) || !pessoa_params[:stack].all? { |s| s.is_a?(String) })
        head :bad_request
        return
      end
      return true
    end
end
