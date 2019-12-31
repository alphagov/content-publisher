# frozen_string_literal: true

RSpec.describe WhitehallImporter::EditionHistory do
  shared_examples "an event bang method" do |method, args = []|
    let(:instance) { described_class.new([]) }
    let(:bang_method) { "#{method}!".to_sym }

    it "delegates to ##{method}" do
      event = build(:revision_history_event)
      expect(instance).to receive(method).and_return(event)
      expect(instance.public_send(bang_method, *args)).to be(event)
    end

    it "raises an AbortImportError if the event is not found" do
      expect(instance).to receive(method).and_return(nil)
      expect { instance.public_send(bang_method, *args) }
        .to raise_error(WhitehallImporter::AbortImportError)
    end
  end

  describe "#last_state_event" do
    it "returns the last event associated with the state" do
      first_draft_event = build(:revision_history_event, state: "draft")
      last_draft_event = build(:revision_history_event, state: "draft")
      instance = described_class.new([first_draft_event, last_draft_event])

      expect(instance.last_state_event("draft")).to be(last_draft_event)
    end

    it "returns nil if the edition is missing a state event" do
      draft_event = build(:revision_history_event, state: "draft")
      expect(described_class.new([draft_event]).last_state_event("published"))
        .to be_nil
    end
  end

  describe "#last_state_event!" do
    it_behaves_like "an event bang method", :last_state_event, %w[draft]
  end

  describe "#next_event" do
    it "returns the event associated with the state" do
      first_event = build(:revision_history_event)
      next_event = build(:revision_history_event)
      instance = described_class.new([first_event, next_event])

      expect(instance.next_event(first_event)).to be(next_event)
    end

    it "returns nil when a next event is not found" do
      event = build(:revision_history_event)
      expect(described_class.new([]).next_event(event)).to be_nil
    end
  end

  describe "#next_event!" do
    it_behaves_like "an event bang method",
                    :next_event,
                    [FactoryBot.build(:revision_history_event)]
  end

  describe "#create_event" do
    it "returns the first create event associated" do
      first_event = build(:revision_history_event, event: "update")
      first_create_event = build(:revision_history_event, event: "create")
      last_create_event = build(:revision_history_event, event: "create")
      instance = described_class.new([first_event, first_create_event, last_create_event])

      expect(instance.create_event).to be(first_create_event)
    end

    it "returns nil if the edition is missing a create event" do
      event = build(:revision_history_event, event: "update")
      expect(described_class.new([event]).create_event).to be_nil
    end
  end

  describe "#create_event!" do
    it_behaves_like "an event bang method", :create_event
  end

  describe "#last_unpublishing_event" do
    it "returns the draft that follows a published event" do
      first_publishing_event = build(:revision_history_event, state: "published")
      first_unpublishing_event = build(:revision_history_event, state: "draft")
      last_publishing_event = build(:revision_history_event, state: "published")
      last_unpublishing_event = build(:revision_history_event, state: "draft")
      instance = described_class.new([first_publishing_event,
                                      first_unpublishing_event,
                                      last_publishing_event,
                                      last_unpublishing_event])

      expect(instance.last_unpublishing_event).to eq(last_unpublishing_event)
    end

    it "returns nil if there is not a draft update that follows a published event" do
      publishing_event = build(:revision_history_event, state: "published")
      next_event = build(:revision_history_event, state: "withdrawn")
      instance = described_class.new([publishing_event, next_event])

      expect(instance.last_unpublishing_event).to be_nil
    end
  end

  describe "#last_unpublishing_event!" do
    it_behaves_like "an event bang method", :last_unpublishing_event
  end

  describe "#edited_after_unpublishing?" do
    it "returns true if there are events after the unpublishing" do
      publishing_event = build(:revision_history_event, state: "published")
      unpublishing_event = build(:revision_history_event, state: "draft")
      edit_event = build(:revision_history_event,
                         state: "draft",
                         created_at: 5.minutes.from_now.rfc3339)
      instance = described_class.new([publishing_event,
                                      unpublishing_event,
                                      edit_event])

      expect(instance.edited_after_unpublishing?).to be(true)
    end

    it "returns false if there aren't edits after unpublishing" do
      publishing_event = build(:revision_history_event, state: "published")
      unpublishing_event = build(:revision_history_event, state: "draft")
      instance = described_class.new([publishing_event, unpublishing_event])

      expect(instance.edited_after_unpublishing?).to be(false)
    end

    it "returns false if the edition doesn't appear unpublished" do
      instance = described_class.new([])
      expect(instance.edited_after_unpublishing?).to be(false)
    end
  end

  describe "#editors" do
    it "returns all of the editors who have contributed to an edition" do
      first_event = build(:revision_history_event, whodunnit: 1)
      second_event = build(:revision_history_event, whodunnit: 2)

      instance = described_class.new([first_event, second_event])

      expect(instance.editors.count).to eq(2)
      expect(instance.editors).to eq([1, 2])
    end

    it "doesn't return the same editor more than once" do
      first_event = build(:revision_history_event, whodunnit: 1)
      second_event = build(:revision_history_event, whodunnit: 1)

      instance = described_class.new([first_event, second_event])

      expect(instance.editors.count).to eq(1)
      expect(instance.editors).to eq([1])
    end
  end
end
