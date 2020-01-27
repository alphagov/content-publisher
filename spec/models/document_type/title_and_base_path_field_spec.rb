# frozen_string_literal: true

RSpec.describe DocumentType::TitleAndBasePathField do
  describe "#payload" do
    it "returns a hash with title and routing attributes" do
      edition = build(:edition, title: "Some title", base_path: "/foo/bar/baz")
      payload = subject.payload(edition)

      expect(payload).to eq(
        title: "Some title",
        base_path: "/foo/bar/baz",
        routes: [{ path: "/foo/bar/baz", type: "exact" }],
      )
    end
  end
end
