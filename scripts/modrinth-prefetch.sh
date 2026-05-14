#!/bin/bash

: << 'END_COMMENT'
Input file can be obtained by exporting custom template:
{
  "url": "{url}",
  "version": "{version}",
  "filename": "{filename}"
},
And modifying into a proper json array of objs.

For curseforge, go to the relevant file page, the url should end in .../{id}
The download URL should have the format:
https://edge.forgecdn.net/files/<first4_id>/<rest_id>/<filename>.jar
END_COMMENT

function print_mod_nix() {
  echo "$project_name = $(nix-modrinth-prefetch "$version_id");"
}

if [ $# -lt 1 ]; then
    echo "Prints nix attr-bindings for modrinth mods" >&2
    echo "Usage: $0 <json-file>" >&2
    exit 1
fi

input_file="$1"

if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' not found" >&2
    exit 1
fi

# Loop through each object in the JSON array
jq -c '.[]' "$input_file" | while read -r obj; do
    url=$(echo "$obj" | jq -r '.url')
    version=$(echo "$obj" | jq -r '.version')
    filename=$(echo "$obj" | jq -r '.filename // empty')
    
    if [[ "$url" != https://modrinth* ]]; then
        continue
    fi
    
    # Extract project ID (last part after last slash)
    project_id="${url##*/}"

    api_response=$(curl -s "https://api.modrinth.com/v2/project/$project_id")

    if [ $? -ne 0 ]; then
      echo "Error: Failed to fetch project info for project '$project_id'" >&2
      continue
    fi

    project_name=$(echo "$api_response" | jq -r '.slug')
    
    api_response=$(curl -s "https://api.modrinth.com/v2/project/$project_id/version")
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch versions for project '$project_id'" >&2
        continue
    fi

    # Filter by version equality and check for neoforge loader
    version_id=$(echo "$api_response" | jq -r \
        ".[] | select(.version_number == \"$version\" and (.loaders | contains([\"neoforge\"]))) | .id" \
        | head -n 1)
    
    if [ -n "$version_id" ] && [ "$version_id" != "null" ]; then
        print_mod_nix
    else
        # Fallback: try to match by filename in the files array
        if [ -n "$filename" ] && [ "$filename" != "null" ]; then
            # Search through all versions for one with matching filename
            version_id=$(echo "$api_response" | jq -r \
                ".[] | select(.files | map(.filename) | contains([\"$filename\"])) | .id" \
                | head -n 1)
            
            if [ -n "$version_id" ] && [ "$version_id" != "null" ]; then
                print_mod_nix
                continue
            fi
        fi
        echo "Warning: No matching version found for project '$project_id' version '$version' with neoforge loader" >&2
    fi
done
