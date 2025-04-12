require 'spec_helper'
require_relative '../lib/client_lookup'

RSpec.describe ClientLookup do
    describe "#name" do
        it "outputs a search message with the provided name" do
            expect {
                described_class.start(["name", "Josh"])
            }.to output(/Searching for client\(s\) with name: Josh/).to_stdout
        end
    end

    describe "#duplicate_emails" do
        it "outputs a search message for duplicate emails" do
        expect {
            described_class.start(["duplicate_emails"])
            }.to output(/Searching for clients with duplicate email addresses/).to_stdout
        end
    end
end