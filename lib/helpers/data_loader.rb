require 'json'
require 'net/http'
require 'uri'
require_relative '../models/client'

module Helpers
  module DataLoader
    # Define custom exceptions
    class DataError < StandardError; end
    class NetworkError < DataError; end
    class ParseError < DataError; end
    class FileError < DataError; end

    def load_client_data
      source = options[:client_json_path]
      puts "\e[33m Using client data from: #{source}\e[0m" 
      
      # Load raw data
      raw_data = if url?(source)
        load_from_url(source)
      else
        load_from_file(source)
      end
      
      # Convert raw JSON data to Client objects
      Models::Client.from_json_array(raw_data)
    end
    
    def url?(string)
      uri = URI.parse(string)
      uri.scheme == 'http' || uri.scheme == 'https'
    rescue URI::InvalidURIError
      false
    end
    
    def load_from_url(url)
      begin
        uri = URI(url)
        response = Net::HTTP.get_response(uri)
        
        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        else
          raise NetworkError, "Failed to fetch data: HTTP #{response.code} - #{response.message}"
        end
      rescue SocketError, Timeout::Error => e
        raise NetworkError, "Network error when accessing #{url}: #{e.message}"
      rescue JSON::ParserError => e
        raise ParseError, "Invalid JSON data at #{url}: #{e.message}"
      end
    end
    
    def load_from_file(filepath)
      begin
        unless File.exist?(filepath)
          raise FileError, "JSON file not found: #{filepath}"
        end
        
        JSON.parse(File.read(filepath))
      rescue JSON::ParserError => e
        raise ParseError, "Invalid JSON in file #{filepath}: #{e.message}"
      rescue Errno::EACCES => e
        raise FileError, "Permission denied when reading #{filepath}"
      end
    end
  end
end