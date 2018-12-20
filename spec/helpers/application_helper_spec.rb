# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  describe "formats a body of text" do
    it "returns a hyper link when given a URI" do
      text = "govuk lives here - https://www.gov.uk/"
      expect(helper.escape_and_link(text)).to match("govuk lives here - <a href=\"https://www.gov.uk/\">https://www.gov.uk/</a>")
    end

    it "returns a mailto link when given a email address" do
      text = "You can email me here - email123@gmail.com"
      expect(helper.escape_and_link(text)).to match("You can email me here - <a href=\"mailto:email123@gmail.com\">email123@gmail.com</a>")
    end

    it "returns a body of text that converts html tags to html entities " do
      text = "Some html tags <p><b>bold paragraph</b></p>"
      expect(helper.escape_and_link(text)).to match("Some html tags &lt;p&gt;&lt;b&gt;bold paragraph&lt;/b&gt;&lt;/p&gt;")
    end
  end
end
