require "with_advisory_lock/base"

RSpec.describe ApplicationJob do
  describe "#run_exclusively" do
    let(:result) { WithAdvisoryLock::Result.new(true) }

    it "runs the block within an advisory lock with a 0 timeout" do
      code_block = double
      expect(code_block).to receive(:run)

      allow(ApplicationRecord)
        .to receive(:with_advisory_lock_result)
        .and_yield
        .and_return(result)

      described_class.new.run_exclusively { code_block.run }

      expect(ApplicationRecord)
        .to have_received(:with_advisory_lock_result)
        .with(instance_of(String), a_hash_including(timeout_seconds: 0))
    end

    it "returns the result of the block" do
      id = SecureRandom.uuid
      returned_result = described_class.new.run_exclusively { id }
      expect(returned_result).to eq(id)
    end

    it "logs when a lock can't be acquired" do
      job = described_class.new
      allow(ApplicationRecord)
        .to receive(:with_advisory_lock_result)
        .and_return(WithAdvisoryLock::Result.new(false))

      expect(job.logger)
        .to receive(:info)
        .with("Job skipped as exclusive lock 'content-publisher:ApplicationJob' could not be acquired")

      job.run_exclusively
    end

    it "runs within a transaction" do
      allow(ApplicationRecord).to receive(:transaction).and_yield
      allow(ApplicationRecord)
        .to receive(:with_advisory_lock_result)
        .with(instance_of(String), a_hash_including(transaction: true))
        .and_return(result)

      described_class.new.run_exclusively

      expect(ApplicationRecord).to have_received(:transaction)
    end

    it "defaults to using the class name for the lock name" do
      klass = Class.new(described_class)
      allow(klass).to receive(:name).and_return("MyJob")
      allow(ApplicationRecord).to receive(:with_advisory_lock_result).and_return(result)

      klass.new.run_exclusively

      expect(ApplicationRecord)
        .to have_received(:with_advisory_lock_result)
        .with("content-publisher:MyJob", instance_of(Hash))
    end

    it "can accept the lock name as an argument" do
      allow(ApplicationRecord)
        .to receive(:with_advisory_lock_result)
        .and_return(result)

      described_class.new.run_exclusively(lock_name: "lock-name")

      expect(ApplicationRecord)
        .to have_received(:with_advisory_lock_result)
        .with("content-publisher:lock-name", instance_of(Hash))
    end
  end
end
