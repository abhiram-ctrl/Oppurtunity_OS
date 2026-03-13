#!/bin/bash
# Test script for Step 5: Gemini AI Extraction

echo "Step 5: Testing Gemini AI Extraction Endpoint"
echo "=============================================="
echo ""

# Check if server is running
echo "1. Testing if backend server is running..."
curl -s -o /dev/null -w "%{http_code}" http://0.0.0.0:5000/test
echo ""
echo ""

# Test import-notification endpoint
echo "2. Testing POST /import-notification endpoint..."
echo ""
echo "Test Case 1: Valid Google internship message"
curl -X POST http://0.0.0.0:5000/import-notification \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Google AI Internship opening for summer 2026. Apply before 14 March at https://careers.google.com"
  }' \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo ""

echo "Test Case 2: Invalid message (empty)"
curl -X POST http://0.0.0.0:5000/import-notification \
  -H "Content-Type: application/json" \
  -d '{}' \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo ""

echo "3. Getting all opportunities..."
curl -X GET http://0.0.0.0:5000/opportunities \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "=============================================="
echo "Testing complete!"
