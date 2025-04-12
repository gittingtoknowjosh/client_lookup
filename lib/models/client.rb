module Models
    # Define validation error class
    class ValidationError < StandardError; end
  
    class Client
      attr_reader :id, :full_name, :email
      
      def initialize(attributes = {})
        @id = attributes['id']
        @full_name = attributes['full_name']
        @email = attributes['email']
      end
      
      # Case insensitive name matching
      def name_matches?(search_term)
        search_term = search_term.to_s.downcase
        full_name.to_s.downcase.include?(search_term)
      end
      
      # Formatted display of client for CLI
      def to_cli_output
        [
          "  Name: #{full_name}",
          "  Email: #{email}",
          "  ID: #{id}"
        ].join("\n")
      end
      
      # Factory method to create clients from JSON data array
      def self.from_json_array(json_data)
        # Validate the data before processing
        validate_data(json_data)
        
        # Process the validated data
        json_data.each_with_index do |client_data, index|
          validate_fields(client_data, index)
        end
        
        json_data.map { |client_data| new(client_data) }
      end
      
      # Validate the overall client data structure
      def self.validate_data(data)
        if data.nil?
          raise ValidationError, "Client data is nil"
        elsif !data.is_a?(Array)
          raise ValidationError, "Client data is not an array (got #{data.class.name})"
        elsif data.empty?
          raise ValidationError, "Client data array is empty"
        end
        
        # Validation passed, return the data
        data
      end
      
      # Validate required fields for each client
      def self.validate_fields(client, index)
        required_fields = ['id', 'full_name', 'email']
        
        unless client.is_a?(Hash)
          raise ValidationError, "Client at index #{index} is not a hash object"
        end
        
        missing_fields = required_fields.select { |field| client[field].nil? || client[field].to_s.strip.empty? }
        
        unless missing_fields.empty?
          raise ValidationError, "Client at index #{index} is missing required fields: #{missing_fields.join(', ')}"
        end
      end
    end
  end