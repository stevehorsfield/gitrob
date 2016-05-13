Sequel.migration do
  change do
    create_table(:signatures) do
      primary_key :id
      String :rule
      String :sha
    end

    from(:signatures).insert([:rule, :sha], ["Undefined rule", ""])
  
    add_column :flags, :signature_id, Integer, :default => 1
    
    alter_table(:flags) do
      add_foreign_key [:signature_id], :signatures
    end
  end
end
