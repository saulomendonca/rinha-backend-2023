class ContagemPessoasController < ApplicationController
  # GET /pessoas/1
  def show
    PessoasFlushJob.perform_now
    sleep 2
    render json: Pessoa.count
  end
end
