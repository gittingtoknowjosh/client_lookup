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

      def field_matches?(field_name, search_term)
        # Handle nil or empty search term
        return false if search_term.nil? || search_term.strip.empty?
        
        # Validate the field exists
        unless respond_to?(field_name.to_sym)
          raise ArgumentError, "Unknown field: #{field_name}"
        end
        
        # Get the field value
        field_value = send(field_name.to_sym)
        
        # Handle nil field value
        return false if field_value.nil?
        
        # Normalize the search term (downcase and normalize spaces)
        normalized_search = search_term.to_s.downcase.gsub(/\s+/, ' ')
        
        # Normalize the field value (downcase and normalize spaces)
        normalized_value = field_value.to_s.downcase.gsub(/\s+/, ' ')
        
        # Check if normalized value contains the normalized search term
        normalized_value.include?(normalized_search)
      end
      
      # Case insensitive name matching
      def name_matches?(search_term)
        return field_matches?(:full_name, search_term)
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