RSpec.describe BulkData::GovernmentRepository do
  include ActiveJob::TestHelper

  let(:repository) { described_class.new }
  let(:cache_key) { BulkData::GovernmentRepository::CACHE_KEY }

  describe "#find" do
    let(:government) { build(:government) }

    before { populate_government_bulk_data(government) }

    it "can find a government for a particular content id" do
      expect(repository.find(government.content_id)).to eq(government)
    end

    it "raises an error when the government isn't known" do
      content_id = SecureRandom.uuid
      expect { repository.find(content_id) }
        .to raise_error("Government #{content_id} not found")
    end
  end

  describe "#for_date" do
    let(:government) do
      build(:government, started_on: 3.weeks.ago, ended_on: 1.week.ago)
    end

    before { populate_government_bulk_data(government) }

    it "returns the government for that date" do
      expect(repository.for_date(2.weeks.ago)).to eq(government)
    end

    it "returns nil if there isn't a government covering the date" do
      expect(repository.for_date(4.weeks.ago)).to be_nil
    end

    it "returns nil if there isn't a date" do
      expect(repository.for_date(nil)).to be_nil
    end
  end

  describe "#current" do
    it "returns the current government when there is one" do
      government = build(:government, ended_on: nil)
      populate_government_bulk_data(government)
      expect(repository.current).to eq(government)
    end

    it "returns nil when there isn't a current government" do
      populate_government_bulk_data(build(:government, :past))
      expect(repository.current).to be_nil
    end
  end

  describe "#past" do
    it "returns all the governments that aren't current" do
      government_a = build(:government,
                           started_on: Date.parse("2018-11-11"),
                           ended_on: nil)
      government_b = build(:government,
                           started_on: Date.parse("2015-11-11"),
                           ended_on: Date.parse("2018-11-11"))
      government_c = build(:government,
                           started_on: Date.parse("2012-11-11"),
                           ended_on: Date.parse("2015-11-11"))
      populate_government_bulk_data(government_a, government_b, government_c)

      expect(repository.past).to eq([government_c, government_b])
    end

    it "returns empty if there are no past govenments" do
      government = build(:government, ended_on: nil)
      populate_government_bulk_data(government)
      expect(repository.past).to be_empty
    end
  end

  describe "#all" do
    it "returns an array of governments sorted by started on date" do
      government_a = build(:government,
                           started_on: Date.parse("2018-11-11"),
                           ended_on: Date.parse("2019-11-11"))
      government_b = build(:government,
                           started_on: Date.parse("2012-11-11"),
                           ended_on: Date.parse("2015-11-11"))
      government_c = build(:government,
                           started_on: Date.parse("2015-11-11"),
                           ended_on: Date.parse("2018-11-11"))
      populate_government_bulk_data(government_a, government_b, government_c)

      expect(repository.all).to eq([government_b, government_c, government_a])
    end

    it "raises an error and queues a job to populate date when there isn't data" do
      expect { repository.all }
        .to raise_error(BulkData::LocalDataUnavailableError)
      expect(PopulateBulkDataJob).to have_been_enqueued
    end
  end

  describe "#populate_cache" do
    let(:governments) do
      [build(:government), build(:government, :past)]
    end

    let!(:get_editions_request) do
      stub_publishing_api_get_editions(
        governments.map(&:to_h),
        document_types: %w[government],
        fields: %w[content_id locale title details],
        states: %w[published],
        locale: "en",
        per_page: 1000,
      )
    end

    it "populates the cache with governments from the Publishing API" do
      repository.populate_cache
      expect(get_editions_request).to have_been_requested
      expect(repository.all).to match_array(governments)
    end

    it "raises a RemoteDataUnavailableError when Publishing API is unavailable" do
      stub_publishing_api_isnt_available

      expect { repository.populate_cache }
        .to raise_error(BulkData::RemoteDataUnavailableError)
    end

    it "resets the all instance variable to clear memoisation" do
      populate_government_bulk_data

      expect { repository.populate_cache }
        .to change { repository.all.count }.from(0).to(2)
    end

    it "repopulates the cache when it was updated before the older_than time" do
      travel_to(10.minutes.ago) { repository.populate_cache }

      repository.populate_cache(older_than: 5.minutes.ago)
      expect(get_editions_request).to have_been_requested.twice
      expect(repository.all).to match_array(governments)
    end

    it "doesn't repopulate the cache when it was updated after the older_than time" do
      travel_to(2.minutes.ago) { repository.populate_cache }

      repository.populate_cache(older_than: 5.minutes.ago)
      expect(get_editions_request).to have_been_requested.once
      expect(repository.all).to match_array(governments)
    end
  end
end
