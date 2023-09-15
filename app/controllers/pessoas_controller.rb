class PessoasController < ApplicationController
  before_action :set_pessoa, only: %i[ show update destroy ]
  MAX_RESULTS = 50

  # GET /pessoas
  def index
    if params[:t].present?
      term = "%#{params[:t]}%"
      @pessoas = Pessoa
        .where(
          "apelido ilike :term OR nome ilike :term OR array_to_string(stack, ',', '*') ilike :term",
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
      render json: @pessoa
    else
      head :not_found
    end
  end

  # POST /pessoas
  def create
    return unless validate_params

    @pessoa = Pessoa.new(pessoa_params)


    if @pessoa.save
      render json: @pessoa, status: :created, location: "/pessoas/#{@pessoa.id}"
    else
      render json: @pessoa.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pessoas/1
  def update
    if @pessoa.update(pessoa_params)
      render json: @pessoa
    else
      render json: @pessoa.errors, status: :unprocessable_entity
    end
  end

  # DELETE /pessoas/1
  def destroy
    @pessoa.destroy
  end

  private
    def set_pessoa
      @pessoa = Pessoa.find_by(id: params[:id])
    end

    def pessoa_params
      params.require(:pessoa).permit(:apelido, :nome, :nascimento, :stack => [])
    end

    def validate_params
      if pessoa_params[:apelido] && !pessoa_params[:apelido].is_a?(String)
        render json: { base: 'invalid parameters' }, status: :bad_request
        return
      end

      if pessoa_params[:nome] && !pessoa_params[:nome].is_a?(String)
        render json: { base: 'invalid parameters' }, status: :bad_request
        return
      end

      date_format = /\A(19|20)[0-9]{2}-(0[1-9]|1[12])-([012][0-9]|3[01])\Z/
      if pessoa_params[:nascimento] && (!pessoa_params[:nascimento].is_a?(String) || !pessoa_params[:nascimento]&.match?(date_format))
        render json: { base: 'invalid parameters' }, status: :bad_request
        return
      end

      if pessoa_params[:stack] && (!pessoa_params[:stack].is_a?(Array) || !pessoa_params[:stack].all? { |s| s.is_a?(String) })
        render json: { base: 'invalid parameters' }, status: :bad_request
        return
      end
      return true
    end
end
