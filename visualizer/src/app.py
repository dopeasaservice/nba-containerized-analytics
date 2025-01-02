import os
import logging
from pathlib import Path
import pandas as pd
from flask import Flask, jsonify, render_template
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)
load_dotenv()

class DataManager:
    def __init__(self):
        self.data_path = "/data/analyzed"
        
    def load_rankings(self):
        try:
            return pd.read_parquet(f"{self.data_path}/player_rankings.parquet")
        except Exception as e:
            logger.error(f"Failed to load player rankings: {e}")
            return None
            
    def load_team_stats(self):
        try:
            return pd.read_parquet(f"{self.data_path}/team_stats.parquet")
        except Exception as e:
            logger.error(f"Failed to load team stats: {e}")
            return None

data_manager = DataManager()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/player-rankings')
def player_rankings():
    df = data_manager.load_rankings()
    if df is None:
        return jsonify({'error': 'Failed to load player rankings'}), 500
        
    rankings = df.head(50).to_dict(orient='records')
    return jsonify(rankings)

@app.route('/api/team-stats')
def team_stats():
    df = data_manager.load_team_stats()
    if df is None:
        return jsonify({'error': 'Failed to load team statistics'}), 500
        
    stats = df.reset_index().to_dict(orient='records')
    return jsonify(stats)

@app.errorhandler(404)
def not_found_error(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
