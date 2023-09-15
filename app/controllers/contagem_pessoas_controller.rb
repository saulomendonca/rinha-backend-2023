class ContagemPessoasController < ApplicationController
  # GET /pessoas/1
  def show
    render json: Pessoa.count
  end
end
