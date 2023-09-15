class CreatePessoas < ActiveRecord::Migration[7.0]
  def change
    create_table :pessoas, id: :uuid do |t|
      t.string :apelido, null: false
      t.string :nome, null: false
      t.date :nascimento, null: false
      t.string :stack, array: true

      t.timestamps
    end
    add_index :pessoas, :stack, using: 'gin'
  end
end
