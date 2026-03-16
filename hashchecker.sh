#!/bin/bash


# edit this base on your token 
#To Gather this on your entra > app registrations > create new registrations.
TENANT_ID="PUT TENANT ID HERE" #Directory (Tenant ID)
CLIENT_ID="CLIENT ID HERE" # Application (client ) ID
CLIENT_SECRET="PUT THE CLIENT SECRET VALUE" # Add the crendetials (credentials url) link to create, capture the value quick since it will be masked afterwards
INPUT_FILE="$1"

# Check if input file was provided

if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 <input_file>"
    echo "Example: $0 hashes.txt"
    exit 1
fi

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File $INPUT_FILE not found"
    exit 1
fi

# This is just a filler to check if you can reach the tokens
echo "Getting token..."
response=$(curl -s -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&scope=https://api.securitycenter.microsoft.com/.default" \
    "https://login.microsoftonline.com/$TENANT_ID/oauth2/v2.0/token")

# Check for error
if echo "$response" | grep -q "error"; then
    echo "Token error:"
    echo "$response" | grep -o '"error_description":"[^"]*' | sed 's/"error_description":"//'
    exit 1
fi

token=$(echo "$response" | grep -o '"access_token":"[^"]*' | sed 's/"access_token":"//')

if [ -z "$token" ]; then
    echo "Failed to get token"
    exit 1
fi

echo "Token obtained successfully"
echo " "
echo " "
echo " "
echo " "


total=0
delete_count=0
keep_count=0
review_count=0

# Process each hash from the input file
while IFS= read -r hash || [ -n "$hash" ]; do
    if [ -z "$hash" ] || [[ "$hash" == \#* ]]; then
        continue
    fi
    hash=$(echo "$hash" | xargs)
    total=$((total + 1))
    
    echo "========================================"
    echo "Hash #$total: $hash"
    echo "========================================"
    
    #This will check the hash status only
    echo "Checking hash: $hash"

    # Using your original URL
    status=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $token" "https://api.securitycenter.microsoft.com/api/files/$hash")  #kindly change if your URL is not the same as mine 
     
    if [ "$status" = "200" ]; then
        response=$(curl -s -H "Authorization: Bearer $token" "https://api.securitycenter.microsoft.com/api/files/$hash")  #kindly change if your URL is not the same as mine 
        determination=$(echo "$response" | grep -o '"determination":"[^"]*' | sed 's/"determination":"//')
        
        if [ -z "$determination" ]; then
            determination=$(echo "$response" | grep -o '"determinationType":"[^"]*' | sed 's/"determinationType":"//')
        fi
        
        echo "STATUS: 200 FOUND"
        echo "DETERMINATION: $determination"
   
        if [[ "$determination" == *"Malware"* ]] || [[ "$determination" == *"Malicious"* ]] || [[ "$determination" == *"Clean"* ]]; then
            echo "ACTION: DELETE"
            delete_count=$((delete_count + 1))
        else
            echo "ACTION: KEEP"
            keep_count=$((keep_count + 1))
        fi
        
    elif [ "$status" = "404" ]; then
        echo "STATUS: 404 NOT FOUND"
        echo "ACTION: KEEP"
        keep_count=$((keep_count + 1))
    else
        echo "STATUS: $status ERROR"
        echo "ACTION: REVIEW"
        review_count=$((review_count + 1))
    fi
    
    echo " "
    sleep 0.5
    
done < "$INPUT_FILE"


echo "========================================"
echo "COMPLETE SUMMARY"
echo "========================================"
echo "Total hashes processed: $total"
echo "To DELETE: $delete_count"
echo "To KEEP: $keep_count"
echo "To REVIEW: $review_count"
echo "========================================"
