require 'spec_helper'
require_relative '../../lib/models/client'

RSpec.describe Models::Client do
  describe '#initialize' do
    it 'initializes with valid attributes' do
      attributes = {
        'id' => 1,
        'full_name' => 'John Doe',
        'email' => 'john.doe@example.com'
      }
      
      client = described_class.new(attributes)
      
      expect(client.id).to eq(1)
      expect(client.full_name).to eq('John Doe')
      expect(client.email).to eq('john.doe@example.com')
    end
    
    it 'initializes with empty attributes' do
      client = described_class.new
      
      expect(client.id).to be_nil
      expect(client.full_name).to be_nil
      expect(client.email).to be_nil
    end
  end
  
  describe '#name_matches?' do
    let(:client) { described_class.new('full_name' => 'John Doe') }
    
    it 'returns true for exact name match' do
      expect(client.name_matches?('John Doe')).to be true
    end
    
    it 'returns true for partial name match' do
      expect(client.name_matches?('John')).to be true
      expect(client.name_matches?('Doe')).to be true
    end
    
    it 'returns false for empty string search term' do
      expect(client.name_matches?('')).to be false
    end
    
    it 'handles whitespace-only search term' do
      expect(client.name_matches?('   ')).to be false
    end
    
    it 'handles special characters in names' do
      special_client = described_class.new('full_name' => 'John-Paul O\'Connor')
      expect(special_client.name_matches?('-Paul')).to be true
      expect(special_client.name_matches?("O'C")).to be true
    end
    
    it 'matches middle names' do
      middle_name_client = described_class.new('full_name' => 'John Middle Doe')
      expect(middle_name_client.name_matches?('Middle')).to be true
    end
    
    it 'returns false when search term contains name but is not part of it' do
      expect(client.name_matches?('Johnson')).to be false
    end
    
    it 'handles names with multiple spaces' do
      spaced_client = described_class.new('full_name' => 'John  Doe')
      expect(spaced_client.name_matches?('John Doe')).to be true
    end
  end
  
  describe '#to_cli_output' do
    it 'formats client info for CLI display' do
      client = described_class.new({
        'id' => 42,
        'full_name' => 'Jane Smith',
        'email' => 'jane@example.com'
      })
      
      expected_output = [
        '  Name: Jane Smith',
        '  Email: jane@example.com',
        '  ID: 42'
      ].join("\n")
      
      expect(client.to_cli_output).to eq(expected_output)
    end
    
    it 'handles nil values in formatting' do
      client = described_class.new({
        'id' => nil,
        'full_name' => nil,
        'email' => nil
      })
      
      expected_output = [
        '  Name: ',
        '  Email: ',
        '  ID: '
      ].join("\n")
      
      expect(client.to_cli_output).to eq(expected_output)
    end
  end
  
  describe '.from_json_array' do
    it 'creates multiple clients from valid JSON array' do
      json_data = [
        { 'id' => 1, 'full_name' => 'Client One', 'email' => 'one@example.com' },
        { 'id' => 2, 'full_name' => 'Client Two', 'email' => 'two@example.com' }
      ]
      
      clients = described_class.from_json_array(json_data)
      
      expect(clients).to be_an(Array)
      expect(clients.length).to eq(2)
      expect(clients.first).to be_a(described_class)
      expect(clients.first.full_name).to eq('Client One')
      expect(clients.last.full_name).to eq('Client Two')
    end
    
    it 'raises ValidationError when data is nil' do
      expect {
        described_class.from_json_array(nil)
      }.to raise_error(Models::ValidationError, "Client data is nil")
    end
    
    it 'raises ValidationError when data is not an array' do
      expect {
        described_class.from_json_array("not an array")
      }.to raise_error(Models::ValidationError, "Client data is not an array (got String)")
    end
    
    it 'raises ValidationError when array is empty' do
      expect {
        described_class.from_json_array([])
      }.to raise_error(Models::ValidationError, "Client data array is empty")
    end
  end
  
  describe '.validate_fields' do
    it 'passes validation for client with all required fields' do
      client_data = { 'id' => 1, 'full_name' => 'John', 'email' => 'john@example.com' }
      
      # No exception should be raised
      expect { 
        described_class.validate_fields(client_data, 0) 
      }.not_to raise_error
    end
    
    it 'raises ValidationError when client is not a hash' do
      expect {
        described_class.validate_fields("not a hash", 0)
      }.to raise_error(Models::ValidationError, "Client at index 0 is not a hash object")
    end
    
    it 'raises ValidationError when required fields are missing' do
      client_data = { 'id' => 1 }  # missing full_name and email
      
      expect {
        described_class.validate_fields(client_data, 0)
      }.to raise_error(Models::ValidationError, /Client at index 0 is missing required fields/)
    end
    
    it 'raises ValidationError when required fields are empty' do
      client_data = { 'id' => 1, 'full_name' => '', 'email' => '  ' }
      
      expect {
        described_class.validate_fields(client_data, 0)
      }.to raise_error(Models::ValidationError, /Client at index 0 is missing required fields/)
    end
  end
end
