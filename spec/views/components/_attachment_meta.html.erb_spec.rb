RSpec.describe "components/_attachment_meta.html.erb", type: :view do
  it "fails to render when no attachment is given" do
    assert_raises do
      render "components/attachment_meta", {}
    end
  end

  it "can include attribute metadata" do
    render "components/attachment_meta", attachment: {
      content_type: "application/pdf",
      file_size: 2048,
      number_of_pages: 2,
    }
    assert_select "abbr.app-c-attachment-meta__abbr[title='Portable Document Format']", text: "PDF"
    expect(rendered).to match(/2 KB/)
    expect(rendered).to match(/2 pages/)
  end

  it "can show file type that doesn't have an abbreviation" do
    render "components/attachment_meta", attachment: {
      content_type: "text/plain",
    }
    expect(rendered).to match(/Plain Text/)
  end

  it "doesn't show metadata information when there isn't any to show" do
    render "components/attachment_meta", attachment: {
      content_type: "unknown/type",
    }
    assert_select ".app-c-attachment-meta__metadata", false
  end

  it "shows reference details on the first metadata line if provided" do
    render "components/attachment_meta", attachment: {
      filename: "department-for-transport-information-asset-register.csv",
      content_type: "application/pdf",
      file_size: 20000,
      number_of_pages: 7,
      isbn: "978-1-5286-1173-2",
      unique_reference: "2259",
      command_paper_number: "Cd. 67",
    }
    assert_select ".app-c-attachment-meta__metadata:nth-of-type(1)", text: "Ref: ISBN 978-1-5286-1173-2, 2259, Cd. 67"
  end

  it "shows unnumbered details on the second metadata line if marked so" do
    render "components/attachment_meta", attachment: {
      filename: "department-for-transport-information-asset-register.csv",
      content_type: "application/pdf",
      file_size: 20000,
      number_of_pages: 7,
      isbn: "978-1-5286-1173-2",
      unique_reference: "2259",
      unnumbered_command_paper: true,
    }
    assert_select ".app-c-attachment-meta__metadata:nth-of-type(2)", text: "Unnumbered command paper"
  end
end
