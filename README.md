# Cal.com FastMCP Server

> ⚠️ **Disclaimer**: This project is not affiliated with or endorsed by Cal.com. I am an independent developer and have no association with Cal.com in any official capacity.

This project provides a FastMCP server for interacting with the Cal.com API. It allows Language Learning Models (LLMs) to use tools to connect with important Cal.com functionalities like managing event types and bookings.

## Prerequisites

- Python 3.8+
- A Cal.com account and API Key (v2)

---

## 🐳 Docker Deployment (Recommended for Unraid)

### Quick Start with Docker Compose

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Danielpeter-99/calcom-mcp.git
   cd calcom-mcp
   ```

2. **Create your `.env` file:**
   ```bash
   cp env.example .env
   ```

3. **Edit `.env` with your configuration:**
   ```bash
   # Required: Your Cal.com API Key
   CALCOM_API_KEY=cal_live_your_api_key_here
   
   # For self-hosted Cal.com instances:
   CALCOM_API_BASE_URL=https://cal-api.kibibit.io/v2
   
   # Port for MCP server
   MCP_PORT=8010
   ```

4. **Build and run:**
   ```bash
   docker-compose up -d --build
   ```

5. **Verify it's running:**
   ```bash
   docker logs calcom-mcp
   ```

### Unraid Community Applications Setup

If you prefer to set up the container manually in Unraid:

1. **Go to Docker tab** → **Add Container**

2. **Configure the container:**
   | Field | Value |
   |-------|-------|
   | Name | `calcom-mcp` |
   | Repository | Build from source or use pre-built image |
   | Network Type | `bridge` |
   | Port Mapping | Host: `8010` → Container: `8010` |

3. **Add Environment Variables:**
   - `CALCOM_API_KEY` = `your_api_key_here` (required)
   - `CALCOM_API_BASE_URL` = `https://cal-api.kibibit.io/v2`
   - `MCP_PORT` = `8010`

4. **Apply and start the container**

### Building the Docker Image Manually

```bash
# Build the image
docker build -t calcom-mcp:latest .

# Run the container
docker run -d \
  --name calcom-mcp \
  --restart unless-stopped \
  -p 8010:8010 \
  -e CALCOM_API_KEY="your_api_key_here" \
  -e CALCOM_API_BASE_URL="https://cal-api.kibibit.io/v2" \
  calcom-mcp:latest
```

### Self-Hosted Cal.com Configuration

For self-hosted Cal.com instances like yours at `cal.kibibit.io`:

| Variable | Description | Example |
|----------|-------------|---------|
| `CALCOM_API_BASE_URL` | Your Cal.com API endpoint (with `/v2`) | `https://cal-api.kibibit.io/v2` |
| `CALCOM_API_KEY` | API key from your Cal.com instance | Get from Settings → Developer → API Keys |

**Note:** The API base URL should point to your API subdomain (`cal-api.kibibit.io`), not your main Cal.com UI (`cal.kibibit.io`).

---

## Local Development Setup

1.  **Clone the repository (if applicable) or download the files.**
    ```bash
    git clone https://github.com/Danielpeter-99/calcom-mcp.git
    cd calcom-mcp
    ```
    
2.  **Create a virtual environment (recommended):**
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows: venv\Scripts\activate
    ```

3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Set up the Cal.com API Key:**
    You need to set the `CALCOM_API_KEY` environment variable. You can get your API key from your Cal.com settings page (usually under Developer or Security settings).

    -   **Linux/macOS:**
        ```bash
        export CALCOM_API_KEY="your_actual_api_key_here"
        export CALCOM_API_BASE_URL="https://cal-api.kibibit.io/v2"  # For self-hosted
        ```
        To make it permanent, add this line to your shell configuration file (e.g., `.bashrc`, `.zshrc`).

    -   **Windows (PowerShell):**
        ```powershell
        $env:CALCOM_API_KEY="your_actual_api_key_here"
        $env:CALCOM_API_BASE_URL="https://cal-api.kibibit.io/v2"  # For self-hosted
        ```
        To make it permanent, you can set it through the System Properties > Environment Variables.

## Running the Server

Once the setup is complete, you can run the FastMCP server:

```bash
fastmcp run app.py --transport sse --port 8010
```

The server will start at localhost:8010, and you should see output indicating it's running. If the `CALCOM_API_KEY` is not set, a warning will be displayed.

---

## Connecting to MCP Clients

### Claude Desktop / Cursor / Other MCP Clients

Add this to your MCP client configuration:

```json
{
  "mcpServers": {
    "calcom": {
      "url": "http://YOUR_UNRAID_IP:8010/sse"
    }
  }
}
```

Replace `YOUR_UNRAID_IP` with your Unraid server's IP address (e.g., `192.168.1.100`).

---

## Available Tools

The server currently provides the following tools for LLM interaction:

-   `get_api_status()`: Check if the Cal.com API key is configured in the environment. Returns a string indicating the status.
-   `list_event_types()`: Fetch a list of all event types from Cal.com for the authenticated account. Returns a dictionary with the list of event types or an error message.
-   `get_bookings(...)`: Fetch a list of bookings from Cal.com, with optional filters (event_type_id, user_id, status, date_from, date_to, limit). Returns a dictionary with the list of bookings or an error message.
-   `create_booking(...)`: Create a new booking in Cal.com for a specific event type and attendee. Requires parameters like start_time, attendee details, and event type identifiers. Returns a dictionary with booking details or an error message.
-   `list_schedules(...)`: List all schedules available to the authenticated user or for a specific user/team. Optional filters: user_id, team_id, limit. Returns a dictionary with the list of schedules or an error message.
-   `list_teams(...)`: List all teams available to the authenticated user. Optional filter: limit. Returns a dictionary with the list of teams or an error message.
-   `list_users(...)`: List all users available to the authenticated account. Optional filter: limit. Returns a dictionary with the list of users or an error message.
-   `list_webhooks(...)`: List all webhooks configured for the authenticated account. Optional filter: limit. Returns a dictionary with the list of webhooks or an error message.

**Note:** All tools require the `CALCOM_API_KEY` environment variable to be set. If it is not set, tools will return a structured error message.

## Tool Usage and Error Handling

- All tools return either the API response (as a dictionary or string) or a structured error message with details about the failure.
- Error messages include the type of error, HTTP status code (if applicable), and the response text from the Cal.com API.
- For best results, always check for the presence of an `error` key in the response before using the returned data.
- Tools are designed to be robust and provide informative feedback for both successful and failed API calls.

## Development Notes

-   The Cal.com API base URL is configurable via the `CALCOM_API_BASE_URL` environment variable (defaults to `https://api.cal.com/v2`).
-   Authentication is primarily handled using a Bearer token with the `CALCOM_API_KEY`.
-   The `create_booking` tool uses the `cal-api-version: 2024-08-13` header as specified in the Cal.com API v2 documentation for that endpoint.
-   Error handling is included in the API calls to provide informative responses.

## 🚀 Built With

[![Python](https://img.shields.io/badge/Python-3.8+-blue?logo=python&logoColor=white)](https://www.python.org/)  
[![FastMCP](https://img.shields.io/badge/FastMCP-Framework-8A2BE2?logo=fastapi&logoColor=white)](https://github.com/jlowin/fastmcp)  
[![Cal.com API](https://img.shields.io/badge/Cal.com%20API-v2-00B8A9?logo=google-calendar&logoColor=white)](https://cal.com/docs/api-reference/v2/introduction)  
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)


## Important Security Note

**Never hardcode your `CALCOM_API_KEY` directly into the source code.** Always use environment variables as described in the setup instructions to keep your API key secure.
