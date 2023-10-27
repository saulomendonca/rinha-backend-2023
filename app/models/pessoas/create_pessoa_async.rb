module Pessoas
  class CreatePessoaAsync
    BUFFER_KEY = 'insert_buffer'.freeze

    def save(pessoa_hash)
      pessoa_hash['stack'] ||= nil
      buffer.push(pessoa_hash)
    end

  private

    def buffer
      @@buffer ||= RedisQueue.new(BUFFER_KEY)
    end
  end
end
