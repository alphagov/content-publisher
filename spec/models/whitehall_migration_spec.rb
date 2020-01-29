# frozen_string_literal: true

RSpec.describe WhitehallMigration do
  describe ".check_migration_completed" do
    context "with only jobs that have finished running" do
      let!(:whitehall_migration) { create(:whitehall_migration) }
      before do
        %i[completed import_aborted import_failed sync_failed].each do |state|
          create(:whitehall_migration_document_import,
                 whitehall_migration_id: whitehall_migration.id,
                 state: state)
        end
      end

      it "updates each of the end times" do
        freeze_time do
          whitehall_migration.check_migration_finished
          expect(whitehall_migration.finished_at).to eq(Time.current)
        end
      end
    end

    context "with some incomplete jobs" do
      let!(:whitehall_migration) { create(:whitehall_migration) }
      before do
        create(:whitehall_migration_document_import, whitehall_migration_id: whitehall_migration["id"], state: "completed")
        create(:whitehall_migration_document_import, whitehall_migration_id: whitehall_migration["id"])
      end

      it "does not update each of the end times" do
        whitehall_migration.check_migration_finished
        expect(whitehall_migration.finished_at).to be_nil
      end
    end
  end
end
