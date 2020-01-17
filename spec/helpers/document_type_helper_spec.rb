# frozen_string_literal: true

RSpec.describe DocumentTypeHelper, type: :helper do
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
        some_document: {
          fields: {
            title: {
              label: "My title",
              description: "...",
            },
          },
        },
        some_document_no_fields_specified: {},
      },
    }
    I18n.backend.store_translations(:en, en)
  end

  describe "#t_doctype_exists?" do
    it "returns true if explicit i18n value exists" do
      expect(t_doctype_exists?("document_types.some_document.fields.title.label")).to be true
    end

    it "returns true if default i18n value exists" do
      expect(t_doctype_exists?("document_types.some_document.fields.foo.label")).to be true
    end

    it "returns false if neither explicit nor default i18n value exists" do
      expect(t_doctype_exists?("document_types.some_document.some_unknown_field")).to be false
    end
  end

  describe "#t_doctype" do
    it "returns the explicit i18n value if it exists" do
      expect(t_doctype("document_types.some_document.fields.title.label")).to eq("My title")
    end

    it "returns 'stringify_keys' hashes if matching multiple properties" do
      expect(t_doctype("document_types.some_document.fields.title")).to eq(
        "label" => "My title",
        "description" => "...",
      )
    end

    it "inherits entire hashes from the default if explicit search has no match" do
      expect(t_doctype("document_types.some_document_no_fields_specified.fields.foo.label")).to eq("Foo")
    end

    it "inherits entire explicit values from the default if explicit search has no match" do
      expect(t_doctype("document_types.some_document.fields.foo.label")).to eq("Foo")
    end

    it "raises a I18n::MissingTranslationData exception if no explicit or default matches" do
      expect { t_doctype("document_types.some_document.some_unknown_field") }
        .to raise_error(
          I18n::MissingTranslationData,
          "translation missing: en.document_types.default.some_unknown_field",
        )
    end
  end
end
