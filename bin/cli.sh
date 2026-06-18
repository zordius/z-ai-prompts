#!/bin/bash

# Get the directory of the script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
# Navigate up to the project root directory
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

list_possible_arguments() {
    echo "Possible prompts are:"
    local first_arg=""
    find "$PROJECT_ROOT" -type f -name "gemini.md" | sed "s|${PROJECT_ROOT}/||" | sed "s|/gemini.md||" | while read -r dir; do
        echo "  - $dir"
        if [ -z "$first_arg" ]; then
            first_arg="$dir"
        fi
    done
    if [ -n "$first_arg" ]; then
        local command_name=$(basename "$0")
        echo ""
        echo "Example: $command_name ocr"
    fi
}

# Construct the absolute path to the gemini.md file based on the first argument
FILE_PATH="${PROJECT_ROOT}/${1}/gemini.md"

if command -v gemini &> /dev/null
then
    # If gemini is found, read the content of the specified file and pass it to gemini
    if [ -f "$FILE_PATH" ]; then
        PROMPT="$(cat "$FILE_PATH")
${*:2}"
        gemini --skip-trust --approval-mode plan -p "$PROMPT"
    elif [ -z "$1" ]; then
        echo "Error: No argument provided. Please specify a prompt."
        list_possible_arguments
        exit 1
    else
        echo "Error: Invalid argument. No prompt found for '$1'"
        list_possible_arguments
        exit 1
    fi
else
    echo "gemini command not found. Attempting to install @google/gemini-cli globally via npm..."
    npm install -g @google/gemini-cli
    if [ $? -eq 0 ]; then
        echo "Installation successful. Please try running the command again."
    else
        echo "Failed to install @google/gemini-cli. Please ensure npm is installed and configured correctly, or install gemini manually."
        exit 1
    fi
fi
