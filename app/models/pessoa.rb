class Pessoa < ApplicationRecord
  validates :apelido, :nascimento, :nome, presence: true

  validates :apelido, length: { in: 1..32 }
  validates :nome, length: { in: 1..100 }
  validates :apelido, uniqueness: true

  validate :validate_date
  validate :validate_stack

  def validate_date
    nascimento.to_date if nascimento.present?
  rescue Date::Error
    errors.add(:nascimento, :invalid)
  end

  def validate_stack
    return true if stack.nil?

    if stack.any?{ |title| title.empty? || title.size > 32 }
      errors.add(:nascimento, :invalid)
    end
  end
end
