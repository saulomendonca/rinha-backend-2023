class AddIndexPessoas < ActiveRecord::Migration[7.0]
  def change
    add_column :pessoas, :searchable, :virtual, type: :text, as: "nome || ' ' || apelido || ' ' || stack", stored: true
    add_index  :pessoas, :searchable, using: :gin, opclass: :gin_trgm_ops
  end
end
