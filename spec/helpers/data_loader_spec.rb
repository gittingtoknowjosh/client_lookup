require 'spec_helper'
require_relative '../../lib/helpers/data_loader'
require_relative '../../lib/models/client'

RSpec.describe Helpers::DataLoader do
  # Create a test class that includes the DataLoader module
  let(:test_class) do
    Class.new do
      include Helpers::DataLoader
      
      attr_accessor :options
      
      def initialize(options = {})
        @options = options
      end
      
      # Override puts to avoid output during tests
      def puts(_)
      end
    end
  end
  
  let(:loader) { test_class.new }
  
  describe '#url?' do
    it 'returns true for valid HTTP URLs' do
      expect(loader.url?('http://example.com/data.json')).to be true
    end
    
    it 'returns true for valid HTTPS URLs' do
      expect(loader.url?('https://api.example.com/clients')).to be true
    end
    
    it 'returns false for file paths' do
      expect(loader.url?('/path/to/file.json')).to be false
      expect(loader.url?('data/clients.json')).to be false
    end
    
    it 'returns false for invalid URLs' do
      expect(loader.url?('not-a-url')).to be false
      expect(loader.url?('ftp://example.com')).to be false
    end
    
    it 'returns false for nil or empty input' do
      expect(loader.url?(nil)).to be false
      expect(loader.url?('')).to be false
    end
  end
  
  describe '#load_from_file' do
    it 'loads and parses a JSON file' do
      file_path = 'data/test_clients.json'
      json_data = [{'id' => 1, 'full_name' => 'Test User', 'email' => 'test@example.com'}]
      
      # Mock File.exist? and File.read
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:read).with(file_path).and_return(JSON.generate(json_data))
      
      result = loader.load_from_file(file_path)
      expect(result).to eq(json_data)
    end
    
    it 'raises FileError when file does not exist' do
      file_path = 'nonexistent_file.json'
      allow(File).to receive(:exist?).with(file_path).and_return(false)
      
      expect {
        loader.load_from_file(file_path)
      }.to raise_error(Helpers::DataLoader::FileError, "JSON file not found: #{file_path}")
    end
    
    it 'raises ParseError when file contains invalid JSON' do
      file_path = 'invalid_json.json'
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:read).with(file_path).and_return('{ invalid json }')
      
      expect {
        loader.load_from_file(file_path)
      }.to raise_error(Helpers::DataLoader::ParseError, /Invalid JSON in file #{file_path}/)
    end
    
    it 'raises FileError when file access is denied' do
      file_path = 'protected_file.json'
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:read).with(file_path).and_raise(Errno::EACCES)
      
      expect {
        loader.load_from_file(file_path)
      }.to raise_error(Helpers::DataLoader::FileError, "Permission denied when reading #{file_path}")
    end
  end
  
  describe '#load_from_url' do
    let(:url) { 'https://api.example.com/clients.json' }
    let(:json_data) { [{'id' => 1, 'full_name' => 'API User', 'email' => 'api@example.com'}] }
    
    it 'loads and parses JSON data from a URL' do
      # Create a mock HTTP response
      mock_response = instance_double("Net::HTTPResponse")
      allow(mock_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      allow(mock_response).to receive(:body).and_return(JSON.generate(json_data))
      
      # Mock the HTTP request
      allow(Net::HTTP).to receive(:get_response).with(URI(url)).and_return(mock_response)
      
      result = loader.load_from_url(url)
      expect(result).to eq(json_data)
    end
    
    it 'raises NetworkError when HTTP request fails' do
      mock_response = instance_double("Net::HTTPResponse")
      allow(mock_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
      allow(mock_response).to receive(:code).and_return('404')
      allow(mock_response).to receive(:message).and_return('Not Found')
      
      allow(Net::HTTP).to receive(:get_response).with(URI(url)).and_return(mock_response)
      
      expect {
        loader.load_from_url(url)
      }.to raise_error(Helpers::DataLoader::NetworkError, "Failed to fetch data: HTTP 404 - Not Found")
    end
    
    it 'raises NetworkError when connection fails' do
      allow(Net::HTTP).to receive(:get_response).with(URI(url)).and_raise(SocketError.new('Failed to open TCP connection'))
      
      expect {
        loader.load_from_url(url)
      }.to raise_error(Helpers::DataLoader::NetworkError, /Network error when accessing #{url}/)
    end
    
    it 'raises ParseError when response contains invalid JSON' do
      mock_response = instance_double("Net::HTTPResponse")
      allow(mock_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      allow(mock_response).to receive(:body).and_return('{ invalid json }')
      
      allow(Net::HTTP).to receive(:get_response).with(URI(url)).and_return(mock_response)
      
      expect {
        loader.load_from_url(url)
      }.to raise_error(Helpers::DataLoader::ParseError, /Invalid JSON data at #{url}/)
    end
  end
  
  describe '#load_client_data' do
    before do
      # Create mock client data and models
      @json_data = [{'id' => 1, 'full_name' => 'Test User', 'email' => 'test@example.com'}]
      @client_objects = [instance_double("Models::Client")]
      
      # Mock the Client.from_json_array method
      allow(Models::Client).to receive(:from_json_array).with(@json_data).and_return(@client_objects)
    end
    
    it 'loads client data from a file when given a file path' do
      file_path = 'data/clients.json'
      loader.options = { client_json_path: file_path }
      
      allow(loader).to receive(:url?).with(file_path).and_return(false)
      allow(loader).to receive(:load_from_file).with(file_path).and_return(@json_data)
      
      result = loader.load_client_data
      expect(result).to eq(@client_objects)
    end
    
    it 'loads client data from a URL when given a URL' do
      url = 'https://api.example.com/clients.json'
      loader.options = { client_json_path: url }
      
      allow(loader).to receive(:url?).with(url).and_return(true)
      allow(loader).to receive(:load_from_url).with(url).and_return(@json_data)
      
      result = loader.load_client_data
      expect(result).to eq(@client_objects)
    end
    
    it 'propagates DataError exceptions' do
      url = 'https://api.example.com/clients.json'
      loader.options = { client_json_path: url }
      
      allow(loader).to receive(:url?).with(url).and_return(true)
      allow(loader).to receive(:load_from_url).with(url).and_raise(Helpers::DataLoader::NetworkError, "Connection failed")
      
      expect {
        loader.load_client_data
      }.to raise_error(Helpers::DataLoader::NetworkError, "Connection failed")
    end
  end
end
