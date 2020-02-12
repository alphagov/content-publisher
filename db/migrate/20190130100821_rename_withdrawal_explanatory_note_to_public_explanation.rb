class RenameWithdrawalExplanatoryNoteToPublicExplanation < ActiveRecord::Migration[5.2]
  def change
    rename_column :withdrawals, :explanatory_note, :public_explanation
    change_column_null :withdrawals, :public_explanation, false
  end
end
