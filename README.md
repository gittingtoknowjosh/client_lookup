# Client Lookup Application

A Ruby CLI tool for efficiently looking up client information from JSON data.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Command Line Interface](#command-line-interface)
  - [Available Commands](#available-commands)
  - [Search by Name](#search-by-name)
  - [Find Duplicate Emails](#find-duplicate-emails)
  - [Client Data Source](#client-data-source)
- [Running Tests](#running-tests)
  - [Prerequisites](#prerequisites-1)
  - [Running All Tests](#running-all-tests)
  - [Running Specific Tests](#running-specific-tests)
  - [Test Output](#test-output)
- [Known Issues](#known-issues)
  - [Thor/RSpec Warning Issue](#thorrspec-warning-issue)
- [Known Limitations and Future Improvements](#known-limitations-and-areas-for-future-improvement)
  - [Current Implementation](#current-implementation)
  - [Limitations & Future Improvements](#limitations--future-improvements)
- [Assumptions and Decisions Made](#assumptions-and-decisions-made)
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

### Running the CLI Tool

You have several options for running the Client Lookup CLI:

#### Option 1: Using Ruby directly

```bash
# On Unix/Linux/macOS/WSL
ruby bin/client_lookup [COMMAND] [ARGUMENTS]

# On Windows
ruby bin\client_lookup [COMMAND] [ARGUMENTS]
```

#### Option 2: Make the script executable (Unix/Linux/macOS/WSL)

Make the script executable once:
```bash
chmod +x bin/client_lookup
```

Then run it directly:
```bash
./bin/client_lookup [COMMAND] [ARGUMENTS]
```

#### Option 3: Using Bundler

```bash
bundle exec ruby bin/client_lookup [COMMAND] [ARGUMENTS]
```

### Command Line Interface

Client Lookup is built using [Thor](https://github.com/rails/thor), a toolkit for building powerful command-line interfaces. This provides us with a consistent interface for all commands, built-in help functionality, and options parsing.

**NOTE: This is using Bundler.**

To see all available commands:
```bash
bundle exec ruby bin/client_lookup help
```

To get help for a specific command:
```bash
bundle exec ruby bin/client_lookup help [COMMAND]
```

### Available Commands

To see all available commands:

```bash
bundle exec ruby bin/client_lookup help
```

### Search by Name

To search for clients by name (including partial matches):

```bash
bundle exec ruby bin/client_lookup name "John"
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
bundle exec ruby bin/client_lookup duplicate_emails
```

Example output:
```bash
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
  ```bash
  # Using the long-form --client-json-path
  bundle exec ruby bin/client_lookup name "John" --client-json-path=/path/to/clients.json
  # OR
  # Using the alias --json
  bundle exec ruby bin/client_lookup duplicate_emails --json=https://api.example.com/clients
  ```

- As an environment variable:
  ```bash
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

5. **Application Interface**:
   - Currently available as CLI tool only
   - Future: Package as a Ruby gem and restructure as a Rails application that uses this gem to provide RESTful API endpoints

6. **Data Sources**:
   - Limited to a single JSON file or endpoint at a time
   - Future: Support searching across multiple JSON files or endpoints simultaneously

## Assumptions and Decisions Made

During the development of this application, several key assumptions and architectural decisions were made:

1. **Data Format**:
   - JSON was chosen as the primary data format for its simplicity and widespread use
   - Assumed that client data would be available either locally or via HTTP endpoint

2. **Command Line Interface**:
   - Thor was selected for CLI implementation due to its robust command structure and built-in help system
   - Commands were designed to be intuitive and follow Unix command conventions

3. **Search Implementation**:
   - Case-insensitive substring matching was implemented as a balance between accuracy and performance
   - Assumed that exact field names would be used for filtering (no field aliases)

4. **Error Handling**:
   - Graceful error handling with user-friendly messages was prioritized over strict validation

5. **Testing Approach**:
   - Unit tests focus on core business logic rather than CLI interaction
   - Mock objects are used to isolate tests from external dependencies

These decisions were made with the intention of creating a maintainable, user-friendly tool that can be extended in the future.

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