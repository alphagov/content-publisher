module RequestExamples
  # an example calling this is expected to provided text of the scenario name
  # and a hash of path helpers with the methods to be checked.
  # Within the example we expect a let of an edition to be defined, which
  # sets up an edition in an incorrect state.
  #
  # For example:
  #   it_behaves_like "requests that assert edition state",
  #                   "situation we're testing against",
  #                   routes: { our_path: %i[get post delete] } do
  #     let(:edition) { create(:edition, :certain_state) }
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

  # an example calling this is expected to provided text of the scenario name,
  # the status code expected and a hash of path helpers with the methods to be
  # checked.
  #
  # For example:
  #   it_behaves_like "requests that return status",
  #                   "scenario we're testing",
  #                   status: :not_found,
  #                   routes: { our_path: %i[get post delete] } do
  #     let(:edition) { create(:edition, :certain_state) }
  #     let(:route_params) { [edition.document] }
  #   end
  #
  shared_examples "requests that return status" do |scenario, status:, routes:|
    describe scenario do
      routes.each do |path, methods|
        methods.each do |method|
          it "returns a #{status} for #{method} #{path}" do
            process(method.to_sym, public_send(path.to_sym, *route_params))

            expect(response).to have_http_status(status)
          end
        end
      end
    end
  end
end
