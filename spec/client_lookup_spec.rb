require 'spec_helper'
require_relative '../lib/client_lookup'

RSpec.describe ClientLookup do
    describe "#name" do
        it "outputs a search message with the provided name" do
            expect {
                described_class.start(["name", "Josh"])
            }.to output(/Searching for client\(s\) with name: Josh/).to_stdout
        end

        it "outputs a message when no clients are found" do
            # Create mock clients that don't match the search term
            mock_clients = [
                double("Client", name_matches?: false),
                double("Client", name_matches?: false)
            ]
            
            # Mock the client_data method
            allow_any_instance_of(ClientLookup).to receive(:client_data).and_return(mock_clients)
            
            expect {
                described_class.start(["name", "Qwertyuiop"])
            }.to output(/No clients found matching 'Qwertyuiop'\./).to_stdout
        end

        it "outputs a message when multiple clients are found" do
            # Create mock clients that match the search term
            mock_clients = [
                double("Client", name_matches?: true, to_cli_output: "Client 1 details"),
                double("Client", name_matches?: true, to_cli_output: "Client 2 details")
            ]
            
            # Mock the client_data method
            allow_any_instance_of(ClientLookup).to receive(:client_data).and_return(mock_clients)
            
            expect {
                described_class.start(["name", "Josh"])
            }.to output(/Found 2 matching client\(s\):/).to_stdout
        end

        it "outputs a message when a single client is found" do
            # Create a single mock client that matches the search term
            mock_clients = [
                double("Client", name_matches?: true, to_cli_output: "Client details"),
                double("Client", name_matches?: false)
            ]
            
            # Mock the client_data method
            allow_any_instance_of(ClientLookup).to receive(:client_data).and_return(mock_clients)
            
            expect {
                described_class.start(["name", "John Doe"])
            }.to output(/Found 1 matching client\(s\):/).to_stdout
        end

        it "outputs a message for partial name matches" do
            # Create mock clients with partial name matches
            mock_clients = [
                double("Client", name_matches?: true, to_cli_output: "Client 1 details"),
                double("Client", name_matches?: true, to_cli_output: "Client 2 details")
            ]
            
            # Mock the client_data method
            allow_any_instance_of(ClientLookup).to receive(:client_data).and_return(mock_clients)
            
            expect {
                described_class.start(["name", "Jo"])
            }.to output(/Found 2 matching client\(s\):/).to_stdout
        end

        it "outputs a message for case-insensitive name matches" do
            # Create mock clients with case-insensitive matches
            mock_clients = [
                double("Client", name_matches?: true, to_cli_output: "Client details")
            ]
            
            # Mock the client_data method
            allow_any_instance_of(ClientLookup).to receive(:client_data).and_return(mock_clients)
            
            expect {
                described_class.start(["name", "jOsh"])
            }.to output(/Found 1 matching client\(s\):/).to_stdout
        end
    end

    describe "#duplicate_emails" do
        it "outputs a search message for duplicate emails" do
            expect {
                described_class.start(["duplicate_emails"])
            }.to output(/Searching for clients with duplicate email addresses/).to_stdout
        end

        it "outputs a message when no duplicate emails are found" do
            # Create mock clients with unique emails
            mock_clients = [
                double("Client", email: "user1@example.com", full_name: "User One", id: 1),
                double("Client", email: "user2@example.com", full_name: "User Two", id: 2),
                double("Client", email: "user3@example.com", full_name: "User Three", id: 3)
            ]
            
            # Mock the client_data method
            allow_any_instance_of(ClientLookup).to receive(:client_data).and_return(mock_clients)
            
            expect {
                described_class.start(["duplicate_emails"])
            }.to output(/No duplicate email addresses found/).to_stdout
        end

        it "outputs a message when duplicate emails are found" do
            # Create mock clients with duplicate emails
            mock_clients = [
                double("Client", email: "shared@example.com", full_name: "User One", id: 1),
                double("Client", email: "shared@example.com", full_name: "User Two", id: 2),
                double("Client", email: "unique@example.com", full_name: "User Three", id: 3)
            ]
            
            # Mock the client_data method
            allow_any_instance_of(ClientLookup).to receive(:client_data).and_return(mock_clients)
            
            expect {
                described_class.start(["duplicate_emails"])
            }.to output(/Found 1 duplicate email\(s\)/).to_stdout
        end

        it "handles multiple sets of duplicate emails" do
            # Create mock clients with multiple duplicate email sets
            mock_clients = [
                double("Client", email: "shared1@example.com", full_name: "User One", id: 1),
                double("Client", email: "shared1@example.com", full_name: "User Two", id: 2),
                double("Client", email: "shared2@example.com", full_name: "User Three", id: 3),
                double("Client", email: "shared2@example.com", full_name: "User Four", id: 4),
                double("Client", email: "unique@example.com", full_name: "User Five", id: 5)
            ]
            
            # Mock the client_data method
            allow_any_instance_of(ClientLookup).to receive(:client_data).and_return(mock_clients)
            
            expect {
                described_class.start(["duplicate_emails"])
            }.to output(/Found 2 duplicate email\(s\)/).to_stdout
        end

        it "ignores empty email addresses" do
            # Create mock clients with empty emails
            mock_clients = [
                double("Client", email: "", full_name: "User One", id: 1),
                double("Client", email: "", full_name: "User Two", id: 2),
                double("Client", email: "unique@example.com", full_name: "User Three", id: 3)
            ]
            
            # Mock the client_data method
            allow_any_instance_of(ClientLookup).to receive(:client_data).and_return(mock_clients)
            
            expect {
                described_class.start(["duplicate_emails"])
            }.to output(/No duplicate email addresses found/).to_stdout
        end

        it "handles case-insensitive email comparison" do
            # Create mock clients with same email in different cases
            mock_clients = [
                double("Client", email: "Shared@Example.com", full_name: "User One", id: 1),
                double("Client", email: "shared@example.com", full_name: "User Two", id: 2),
                double("Client", email: "unique@example.com", full_name: "User Three", id: 3)
            ]
            
            # Mock the client_data method
            allow_any_instance_of(ClientLookup).to receive(:client_data).and_return(mock_clients)
            
            expect {
                described_class.start(["duplicate_emails"])
            }.to output(/Found 1 duplicate email\(s\)/).to_stdout
        end
    end
end