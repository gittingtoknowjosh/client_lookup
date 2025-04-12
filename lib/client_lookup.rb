require 'thor'
require_relative 'helpers/data_loader'

class ClientLookup < Thor
    include Helpers::DataLoader

    class_option :client_json_path,
        type: :string,
        desc: "Path to local JSON file or URL to JSON endpoint",
        default: ENV['CLIENT_JSON_PATH'] || 'data/sample_clients.json',
        aliases: ['--json', '--client-json-path']
    
    no_commands do
        def client_data
            @client_data ||= begin
                load_client_data
            rescue Helpers::DataLoader::DataError => e
                puts "Error loading client data: #{e.message}"
                exit(1)  # Exit with error code
            end
        end
    end

    desc "name NAME", "Search for a client by name (partial matches included)."
    def name(search_term)
        puts "Searching for client(s) with name: #{search_term}"
        # Get the client data
        clients = client_data
        
        # Search for clients with matching names
        matching_clients = clients.select { |client| client.name_matches?(search_term) }
        
        # Display results
        if matching_clients.empty?
        puts "No clients found matching '#{search_term}'."
        else
        puts "Found #{matching_clients.count} matching client(s):"
        puts "-" * 50
        
        matching_clients.each_with_index do |client, index|
            puts "Client ##{index + 1}:"
            puts client.to_cli_output
            puts "-" * 50
        end
        end
    end
    
    desc "duplicate_emails", "Find clients with the same email addresses."
    def duplicate_emails
        puts "Searching for clients with duplicate email addresses..."
        
        # Get the client data
        clients = client_data
        
        # Group clients by email
        grouped = clients.group_by { |client| client.email.to_s.downcase }
        
        # Filter to only emails with duplicates
        duplicates = grouped.select { |email, clients_array| clients_array.size > 1 && !email.empty? }
        
        # Display results
        if duplicates.empty?
        puts "No duplicate email addresses found."
        else
        puts "Found #{duplicates.size} duplicate email(s):"
        puts "-" * 50
        
        duplicates.each_with_index do |(email, clients_array), index|
            puts "Duplicate Email ##{index + 1}: #{email}"
            clients_array.each do |client|
            puts "  - #{client.full_name} (ID: #{client.id})"
            end
            puts "-" * 50
        end
        end
    end
 
    def self.exit_on_failure?
        true
    end
end