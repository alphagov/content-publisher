# frozen_string_literal: true

module AssertEditionStateExamples
  # an example calling this is expected to provided text of the scenario name
  # and an array of methods to be checked.
  # Within the example we expect a let of an edition to be defined, which
  # sets up an edition in an incorrect state and a let of run_request which is
  # a lambda to call to run the request
  #
  # For example:
  #   it_behaves_like "requests that assert edition state",
  #                   "situation we're testing against",
  #                   routes: { our_path: %i[get post delete] } do
  #     let(:edition) { create(:edition, :certain_state) }
  #     let(:route_params) { [edition.document] }
  #   end
  #
  shared_examples "requests that assert edition state" do |scenario, routes:|
    let(:route_params) { [edition.document] }

    describe "Asserting edition state for #{scenario}" do
      routes.each do |path, methods|
        methods.each do |method|
          it "redirects for #{method} #{path}" do
            process(method.to_sym, public_send(path.to_sym, *route_params))

            expect(response).to redirect_to(document_path(edition.document))
          end
        end
      end
    end
  end
end
