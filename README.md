# Client Lookup Application

A Ruby CLI tool for efficiently looking up client information from JSON data.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Running Tests](#running-tests)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Overview

The Client Lookup application is a command-line tool that provides a fast and reliable way to search and retrieve client information from JSON data. It supports searching by client name and finding duplicate email addresses.

## Prerequisites

- Ruby 3.4.2
- Bundler gem

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/gittingtoknowjosh/client_lookup.git
   cd client_lookup
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

## Configuration

1. Copy the example environment file:
   ```bash
   cp .env.template .env
   ```

2. Edit `.env` with your settings:
   ```
   # Path to local JSON file or URL to JSON endpoint that contains client data
   CLIENT_JSON_PATH=data/sample_clients.json
   ```

## Usage

### Command Line Interface

Client Lookup is built using [Thor](https://github.com/rails/thor), a toolkit for building powerful command-line interfaces. This provides us with a consistent interface for all commands, built-in help functionality, and options parsing.

To see all available commands:
```
client_lookup help
```

To get help for a specific command:
```
client_lookup help [COMMAND]
```

### Available Commands

To see all available commands:

```bash
./bin/client_lookup help
```

### Search by Name

To search for clients by name (including partial matches):

```bash
./bin/client_lookup name "John"
```

Example output:
```
Searching for client(s) with name: John
Found 2 matching client(s):
--------------------------------------------------
Client #1:
ID: 1
Name: John Doe
Email: john.doe@example.com
--------------------------------------------------
Client #2:
ID: 2
Name: Johnny Appleseed
Email: johnny.appleseed@example.com
--------------------------------------------------
```

### Find Duplicate Emails

To find clients with duplicate email addresses:

```bash
./bin/client_lookup duplicate_emails
```

Example output:
```
Searching for clients with duplicate email addresses...
Found 1 duplicate email(s):
--------------------------------------------------
Duplicate Email #1: duplicate@example.com
  - Jane Doe (ID: 3)
  - John Smith (ID: 4)
--------------------------------------------------
```
### Client Data Source

The application needs to know where to find client data. You can specify the source using the `client_json_path` option in any of the following ways:

- As a command line option:
  ```
  # Using the long-form --client-json-path
  client_lookup name "John" --client-json-path=/path/to/clients.json
  # OR
  # Using the alias --json
  client_lookup duplicate_emails --json=https://api.example.com/clients
  ```

- As an environment variable:
  ```
  export CLIENT_JSON_PATH=/path/to/clients.json
  ```

- If not specified, it defaults to `data/sample_clients.json` in the project directory

The value can be either:
- A path to a local JSON file
- A URL to a JSON API endpoint

## Running Tests

This project uses RSpec for testing.

### Prerequisites

Ensure you have RSpec installed:

```bash
gem install rspec
```

Or using Bundler:

```bash
bundle install
```

### Running All Tests

To run all tests:

```bash
rspec
```

### Running Specific Tests

To run a specific test file:

```bash
rspec spec/path/to/file_spec.rb
```

To run a specific test or group of tests:

```bash
rspec spec/path/to/file_spec.rb:LINE_NUMBER
```

### Test Output

The test configuration captures standard output and standard error during test execution. This prevents test output from cluttering your terminal while running tests.

## Known Issues

### Thor/RSpec Warning Issue

There is a known issue with Thor and RSpec where running RSpec tests may produce warnings related to Thor commands. This is due to a conflict between Thor's command-line parsing and RSpec's test execution.

#### Workarounds

1. **Suppress Warnings**: You can suppress the warnings by setting the `THOR_SILENCE_DEPRECATION` environment variable to `true`:
   ```bash
   export THOR_SILENCE_DEPRECATION=true
   ```

2. **Use Bundler Exec**: Run RSpec tests using `bundle exec` to ensure the correct environment is used:
   ```bash
   bundle exec rspec
   ```

3. **Update Dependencies**: Ensure you have the latest versions of Thor and RSpec installed, as updates may resolve the issue:
   ```bash
   bundle update thor rspec
   ```

4. **Use Instance Doubles**: Create a specific double for ClientLookup instead of using `allow_any_instance_of`:
   ```ruby
   it "outputs a message when no duplicate emails are found" do
     # Create an instance and stub it directly
     client_lookup = ClientLookup.new
     
     mock_clients = [
       double("Client", email: "user1@example.com", full_name: "User One", id: 1),
       double("Client", email: "user2@example.com", full_name: "User Two", id: 2)
     ]
     
     # Mock on the specific instance
     allow(client_lookup).to receive(:client_data).and_return(mock_clients)
     
     # Call instance method directly
     expect { client_lookup.duplicate_emails }.to output(/No duplicate email addresses found/).to_stdout
   end
   ```

5. **Ignore the Warning**: If the warning does not affect your tests, you can choose to ignore it.

## Known Limitations and Areas for Future Improvement

### Current Implementation
The Client model currently supports basic fields only: `id`, `full_name`, and `email`.

### Limitations & Future Improvements

1. **Client Information**:
   - Limited to basic contact information
   - Future: Add support for addresses, phone numbers, and custom fields

2. **Search Capabilities**:
   - Currently uses simple substring matching
   - Future: Implement fuzzy matching, advanced filters, and search ranking

3. **Data Structure**:
   - No support for nested data or relationships
   - Future: Add support for complex data relationships and enhanced validation

4. **Performance**:
   - Future: Implement pagination, caching, and optimization for large datasets

Additional planned features include data export, audit logging, and external system integration.

## Troubleshooting

If you encounter any issues, please check the following:

- Ensure you have the correct version of Ruby installed.
- Verify that all dependencies are installed by running `bundle install`.
- Check the configuration in your `.env` file.

## Contributing

If you would like to contribute to this project, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes.
4. Submit a pull request.