# Test script for Step 5: Gemini AI Extraction (Windows PowerShell)

Write-Host "Step 5: Testing Gemini AI Extraction Endpoint" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if server is running
Write-Host "1. Testing if backend server is running..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://0.0.0.0:5000/test" -UseBasicParsing
    Write-Host "✓ Server is running (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Server is not running" -ForegroundColor Red
    Write-Host "Please start the server with: node server.js"
    exit
}

Write-Host ""
Write-Host ""

# Test 2: Test import-notification endpoint
Write-Host "2. Testing POST /import-notification endpoint..." -ForegroundColor Yellow
Write-Host ""

# Test Case 1: Valid Google internship message
Write-Host "Test Case 1: Valid Google internship message" -ForegroundColor Magenta
$payload = @{
    message = "Google AI Internship opening for summer 2026. Apply before 14 March at https://careers.google.com"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://0.0.0.0:5000/import-notification" `
        -Method POST `
        -ContentType "application/json" `
        -Body $payload `
        -UseBasicParsing
    Write-Host "✓ Success (Status: $($response.StatusCode))"
    Write-Host $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 2
} catch {
    Write-Host "✗ Error (Status: $($_.Exception.Response.StatusCode))"
    Write-Host $_.Exception.Response.Content
}

Write-Host ""
Write-Host ""

# Test Case 2: Invalid message (empty)
Write-Host "Test Case 2: Invalid message (empty)" -ForegroundColor Magenta
$payload = @{} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://0.0.0.0:5000/import-notification" `
        -Method POST `
        -ContentType "application/json" `
        -Body $payload `
        -UseBasicParsing
    Write-Host "✓ Success (Status: $($response.StatusCode))"
    Write-Host $response.Content
} catch {
    Write-Host "✓ Expected error (Status: $($_.Exception.Response.StatusCode))"
    Write-Host "Error message:"
    Write-Host $_.Exception.Response.Content
}

Write-Host ""
Write-Host ""

# Test 3: Get all opportunities
Write-Host "3. Getting all opportunities..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://0.0.0.0:5000/opportunities" `
        -UseBasicParsing
    Write-Host "✓ Success (Status: $($response.StatusCode))"
    $opportunities = $response.Content | ConvertFrom-Json
    Write-Host "Total opportunities: $($opportunities.Count)"
} catch {
    Write-Host "✗ Error: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Testing complete!" -ForegroundColor Green
