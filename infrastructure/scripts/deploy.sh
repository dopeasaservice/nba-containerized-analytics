#!/bin/bash

set -e

# Configuration
AWS_REGION="us-east-1"
ECR_REPO_PREFIX="nba-analytics"
CLUSTER_NAME="nba-analytics-cluster"
SERVICES=("data-processor" "analytics" "visualizer")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check AWS CLI is installed and configured
if ! command -v aws &> /dev/null; then
    error "AWS CLI is not installed"
fi

# Check Docker is running
if ! docker info &> /dev/null; then
    error "Docker is not running"
fi

# Login to ECR
log "Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Create ECR repositories if they don't exist
for SERVICE in "${SERVICES[@]}"; do
    REPO_NAME="${ECR_REPO_PREFIX}-${SERVICE}"
    if ! aws ecr describe-repositories --repository-names ${REPO_NAME} &> /dev/null; then
        log "Creating ECR repository: ${REPO_NAME}"
        aws ecr create-repository --repository-name ${REPO_NAME} \
            --image-scanning-configuration scanOnPush=true
    fi
done

# Build and push Docker images
for SERVICE in "${SERVICES[@]}"; do
    log "Building ${SERVICE} image..."
    REPO_NAME="${ECR_REPO_PREFIX}-${SERVICE}"
    TAG="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:latest"
    
    docker build -t ${TAG} ./${SERVICE} || error "Failed to build ${SERVICE} image"
    
    log "Pushing ${SERVICE} image to ECR..."
    docker push ${TAG} || error "Failed to push ${SERVICE} image"
done

# Update ECS task definition
log "Updating ECS task definition..."
aws ecs register-task-definition \
    --cli-input-json file://infrastructure/task-definition.json || error "Failed to update task definition"

# Update ECS service
log "Updating ECS service..."
aws ecs update-service \
    --cluster ${CLUSTER_NAME} \
    --service nba-analytics-service \
    --task-definition nba-analytics-task \
    --force-new-deployment || error "Failed to update ECS service"

log "Deployment completed successfully!"
