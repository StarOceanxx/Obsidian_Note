
# Test Claude CLI environment variables
$env:ANTHROPIC_AUTH_TOKEN = "sk-thW2OtoeeG9Mo3dx5e7aFQ"
$env:ANTHROPIC_BASE_URL = "https://litellm.southchips.net/"
$env:ANTHROPIC_MODEL = "claude-3-5-sonnet-20241022"
$env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
$env:API_TIMEOUT_MS = "60000"
$env:CLAUDE_CODE_MAX_OUTPUT_TOKENS = "16000"

Write-Output "Environment variables set:"
Write-Output "ANTHROPIC_AUTH_TOKEN: $env:ANTHROPIC_AUTH_TOKEN"
Write-Output "ANTHROPIC_BASE_URL: $env:ANTHROPIC_BASE_URL"
Write-Output "ANTHROPIC_MODEL: $env:ANTHROPIC_MODEL"
Write-Output ""

Write-Output "Test Claude CLI connection..."
Write-Output "Execute: claude --version"
& claude --version

Write-Output ""
Write-Output "Test simple conversation..."
Write-Output "Execute: echo 'hello' | claude"
$result = echo "hello" | & claude 2>&1
Write-Output "Result:"
Write-Output $result
