RSpec.describe DocumentTypeHelper do
  before do
    en = {
      document_types: {
        default: {
          fields: {
            foo: {
              label: "Foo",
              description: "Foo description",
            },
          },
        },
        news_story: {
          fields: {
            title: {
              label: "My title",
              description: "...",
            },
          },
        },
      },
    }
    I18n.backend.store_translations(:en, en)
  end

  after { I18n.backend.reload! }

  let(:edition) { build(:edition, document_type_id: "news_story") }

  describe "#t_doctype_field?" do
    it "returns true if explicit i18n value exists" do
      expect(t_doctype_field?(edition, "title.label")).to be true
    end

    it "returns true if default i18n value exists" do
      expect(t_doctype_field?(edition, "foo.label")).to be true
    end

    it "returns false if neither explicit nor default i18n value exists" do
      expect(t_doctype_field?(edition, "some_unknown_field")).to be false
    end
  end

  describe "#t_doctype_field" do
    it "returns the explicit i18n value if it exists" do
      expect(t_doctype_field(edition, "title.label")).to eq("My title")
    end

    it "inherits entire explicit values from the default if explicit search has no match" do
      expect(t_doctype_field(edition, "foo.label")).to eq("Foo")
    end

    it "raises a I18n::MissingTranslationData exception if no explicit or default matches" do
      expect { t_doctype_field(edition, "some_unknown_field") }
        .to raise_error(
          I18n::MissingTranslationData,
          "translation missing: en.document_types.default.fields.some_unknown_field",
        )
    end
  end
end
