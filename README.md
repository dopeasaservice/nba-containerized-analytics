# NBA Containerized Analytics

A containerized application for NBA player statistics analysis and visualization.

## Project Structure
nba-containerized-analytics/
├── data-processor/ # Data fetching and processing service
├── analytics/ # Data analysis service
├── visualizer/ # Web visualization service
├── infrastructure/ # AWS and deployment configurations
└── tests/ # Test files
                    
## Local Development Setup
1. Create and activate virtual environment
2. Install dependencies
3. Set up AWS credentials
4. Run local development server

## Deployment
1. Build Docker images
2. Push to ECR
3. Deploy to ECS

## Configuration
Update `.env` file with required credentials and settings.

## License
MIT