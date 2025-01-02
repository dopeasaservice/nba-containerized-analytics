#!/bin/bash

# Add at the beginning of the script
# Get base directory from parameter or use default
BASE_DIR="${1:-nba-dashboard-analytics}"

# Update the verify_directory function
verify_directory() {
    if [ "$(basename $(pwd))" != "$BASE_DIR" ]; then
        error "This script must be run from the '$BASE_DIR' directory. Current directory: $(pwd)"
    fi
    log "Running in correct directory: $BASE_DIR"
}

# Update all directory creation commands to use $BASE_DIR
# For example:
create_directory() {
    local dir_path="$BASE_DIR/$1"
    if [ ! -d "$dir_path" ]; then
        log "Creating directory: $dir_path"
        mkdir -p "$dir_path"
    fi
}


# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Function to create or update a file
create_or_update_file() {
    local file_path="$1"
    local content="$2"
    local dir_path=$(dirname "$file_path")
    
    # Create directory if it doesn't exist
    mkdir -p "$dir_path"
    
    # Check if file exists and content is different
    if [ -f "$file_path" ]; then
        if ! echo "$content" | cmp -s - "$file_path"; then
            log "Updating $file_path"
            echo "$content" > "$file_path"
        else
            log "File $file_path is up to date"
        fi
    else
        log "Creating $file_path"
        echo "$content" > "$file_path"
    fi
}

# Function to create or update a directory
create_directory() {
    local dir_path="$1"
    if [ ! -d "$dir_path" ]; then
        log "Creating directory: $dir_path"
        mkdir -p "$dir_path"
    fi
}

# Function to check and create Python files
create_python_file() {
    local file_path="$1"
    local template="$2"
    
    create_or_update_file "$file_path" "$template"
    
    # Create __init__.py if in a Python package directory
    local dir_path=$(dirname "$file_path")
    if [[ "$file_path" == *"/src/"* ]] || [[ "$file_path" == *"/tests/"* ]] || [[ "$file_path" == *"/utils/"* ]]; then
        touch "$dir_path/__init__.py"
    fi
}

# Setup project structure
setup_project_structure() {
    log "Setting up project structure..."
    
    # Create main directories
    directories=(
        "data-processor/src/utils"
        "data-processor/tests"
        "analytics/src/utils"
        "analytics/tests"
        "visualizer/src/utils"
        "visualizer/tests"
        "visualizer/static/css"
        "visualizer/static/js"
        "visualizer/templates"
        "infrastructure/cloudformation/task-definitions"
        "infrastructure/scripts"
        "utils"
    )
    
    for dir in "${directories[@]}"; do
        create_directory "$dir"
    done
}

# Create data processor files
setup_data_processor() {
    log "Setting up data processor service..."
    
    # Create processor.py
    create_python_file "data-processor/src/processor.py" "$(cat << 'EOL'
#!/usr/bin/env python3
"""
NBA Data Processor Service
Fetches NBA game data and stores it for analysis.
"""
# ... rest of the processor.py content ...
EOL
)"

    # Create nba_api.py
    create_python_file "data-processor/src/utils/nba_api.py" "$(cat << 'EOL'
"""
NBA API Client
Handles interactions with the SportsData.io NBA API.
"""
# ... rest of the nba_api.py content ...
EOL
)"

    # Create Dockerfile
    create_or_update_file "data-processor/Dockerfile" "$(cat << 'EOL'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ ./src/
ENV PYTHONPATH=/app
CMD ["python", "src/processor.py"]
EOL
)"

    # Create requirements.txt
    create_or_update_file "data-processor/requirements.txt" "$(cat << 'EOL'
boto3>=1.26.0
requests>=2.28.0
python-dateutil>=2.8.0
EOL
)"
}

# Create analytics service files
setup_analytics() {
    log "Setting up analytics service..."
    # Similar structure to setup_data_processor
    # ... analytics service setup code ...
}

# Create visualizer service files
setup_visualizer() {
    log "Setting up visualizer service..."
    # Similar structure to setup_data_processor
    # ... visualizer service setup code ...
}

# Create infrastructure files
setup_infrastructure() {
    log "Setting up infrastructure files..."
    # ... infrastructure setup code ...
}

# Create deployment scripts
setup_deployment_scripts() {
    log "Setting up deployment scripts..."
    # ... deployment scripts setup code ...
}

# Create documentation files
setup_documentation() {
    log "Setting up documentation files..."
    
    # Create README.md
    create_or_update_file "README.md" "$(cat << 'EOL'
# NBA Analytics Pipeline Demo
... README content ...
EOL
)"

    # Create .env.example
    create_or_update_file ".env.example" "$(cat << 'EOL'
# Configuration Management
... .env.example content ...
EOL
)"

    # Create .gitignore
    create_or_update_file ".gitignore" "$(cat << 'EOL'
# Python
__pycache__/
*.py[cod]
*$py.class
... rest of .gitignore content ...
EOL
)"

    # Create LICENSE
    create_or_update_file "LICENSE" "$(cat << 'EOL'
MIT License
... LICENSE content ...
EOL
)"

    # Create CONTRIBUTING.md
    create_or_update_file "CONTRIBUTING.md" "$(cat << 'EOL'
# Contributing to NBA Analytics Pipeline Demo
... CONTRIBUTING.md content ...
EOL
)"
}

# Verify project structure
verify_project() {
    log "Verifying project structure..."
    # ... verification code ...
}

# Main execution
main() {
    log "Starting project setup..."
    
    setup_project_structure
    setup_data_processor
    setup_analytics
    setup_visualizer
    setup_infrastructure
    setup_deployment_scripts
    setup_documentation
    verify_project
    
    log "Project setup completed successfully!"
}

# Execute main function
main
