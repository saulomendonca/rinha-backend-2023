require 'test_helper'
require 'sidekiq/testing'
require 'mock_redis'
require 'minitest/autorun'

class PessoasFlushJobTest < ActiveSupport::TestCase

  def pessoa_hash(apelido = "apelidoone", nome = "person one")
    { apelido:, nome:, nascimento: Date.today - 20.years }
  end

  setup do
    Sidekiq::Testing.fake!
  end

  test 'should flushes buffer of pessoas' do
    buffer = RedisQueue.new(Pessoas::CreatePessoaAsync::BUFFER_KEY)
    buffer.clear!

    number_of_people = PessoasFlushJob::BUFFER_SIZE
    number_of_people.times do |i|
      buffer.push(pessoa_hash("apelido#{i}", "person #{1}"))
    end

    assert_equal number_of_people, buffer.size

    PessoasFlushJob.stub_any_instance :buffer, buffer do
      PessoasFlushJob.new.perform
    end

    assert_equal 0, buffer.size
  end

  test 'Should save pessoas' do
    buffer = RedisQueue.new(Pessoas::CreatePessoaAsync::BUFFER_KEY)
    buffer.clear!

    number_of_people = PessoasFlushJob::BUFFER_SIZE
    number_of_people.times do |i|
      buffer.push(pessoa_hash("apelido#{i}", "person #{1}"))
    end

    assert_difference("Pessoa.count", number_of_people) do
      PessoasFlushJob.stub_any_instance :buffer, buffer do
        PessoasFlushJob.new.perform
      end
    end
  end
end
