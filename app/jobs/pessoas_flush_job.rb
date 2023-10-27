require 'sidekiq-scheduler'

class PessoasFlushJob < ActiveJob::Base
  BUFFER_SIZE = ENV.fetch('JOB_BATCH_SIZE', 10).to_i
  queue_as :flush

  def buffer
    @@buffer ||= RedisQueue.new(Pessoas::CreatePessoaAsync::BUFFER_KEY)
  end

  def perform
    return if buffer.size < BUFFER_SIZE
    pessoas_hash = buffer.fetch

    begin
      Pessoa.insert_all(pessoas_hash, returning: false) if pessoas_hash.present?
    rescue => e
      Sidekiq.logger.error "ERROR: #{e} #{pessoas_hash}"
    end
  end
end
