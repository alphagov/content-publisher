# frozen_string_literal: true

require "sidekiq_abort_middleware"

RSpec.describe SidekiqAbortMiddleware do
  context "when a job raises an AbortWorkerError" do
    it "catches the exception and sidekiq logs a warning of the exception message" do
      block = -> { raise AbortWorkerError, "worker was aborted" }

      expect(Sidekiq.logger).to receive(:warn).with("worker was aborted")

      expect { SidekiqAbortMiddleware.new.call(nil, nil, nil, &block) }
        .not_to raise_error
    end
  end

  context "when a job doesn't raise an AbortWorkerError" do
    it "runs the block" do
      ran = false
      SidekiqAbortMiddleware.new.call(nil, nil, nil) { ran = true }
      expect(ran).to be(true)
    end
  end
end
