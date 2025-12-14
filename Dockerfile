FROM python:3.12-slim

LABEL maintainer="Cal.com MCP Server"
LABEL description="FastMCP server for Cal.com API integration"

# Set working directory
WORKDIR /app

# Install dependencies first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash appuser && \
    chown -R appuser:appuser /app
USER appuser

# Expose the default port
EXPOSE 8010

# Environment variables with defaults
ENV CALCOM_API_KEY=""
ENV CALCOM_API_BASE_URL="https://api.cal.com/v2"
ENV MCP_PORT=8010

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:${MCP_PORT}/health', timeout=5)" || exit 1

# Run the FastMCP server with SSE transport
CMD ["sh", "-c", "fastmcp run app.py --transport sse --port ${MCP_PORT} --host 0.0.0.0"]

