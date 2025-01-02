import os
import logging
import pandas as pd
import numpy as np
from pathlib import Path
from sklearn.preprocessing import StandardScaler

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class NBAAnalyzer:
    def __init__(self):
        self.input_path = "/data/processed"
        self.output_path = "/data/analyzed"
        
    def load_latest_data(self):
        try:
            files = list(Path(self.input_path).glob("processed_stats_*.parquet"))
            if not files:
                logger.error("No processed data files found")
                return None
                
            latest_file = max(files, key=lambda x: x.stat().st_mtime)
            return pd.read_parquet(latest_file)
        except Exception as e:
            logger.error(f"Failed to load data: {e}")
            return None

    def calculate_player_rankings(self, df):
        try:
            numerical_cols = ['PointsPerGame', 'EfficiencyRating', 
                            'Rebounds', 'Assists', 'Steals', 'BlockedShots']
            scaler = StandardScaler()
            
            rankings_df = df.copy()
            rankings_df[numerical_cols] = scaler.fit_transform(df[numerical_cols])
            
            rankings_df['OverallScore'] = rankings_df[numerical_cols].mean(axis=1)
            rankings_df['OverallRank'] = rankings_df['OverallScore'].rank(ascending=False)
            rankings_df['ScoringRank'] = rankings_df['PointsPerGame'].rank(ascending=False)
            rankings_df['EfficiencyRank'] = rankings_df['EfficiencyRating'].rank(ascending=False)
            
            return rankings_df
        except Exception as e:
            logger.error(f"Failed to calculate rankings: {e}")
            return None

    def analyze_team_performance(self, df):
        try:
            team_stats = df.groupby('Team').agg({
                'PointsPerGame': 'mean',
                'EfficiencyRating': 'mean',
                'Rebounds': 'sum',
                'Assists': 'sum',
                'Steals': 'sum',
                'BlockedShots': 'sum'
            }).round(2)
            
            team_stats['TeamScore'] = (
                team_stats['PointsPerGame'] * 0.4 +
                team_stats['EfficiencyRating'] * 0.3 +
                team_stats['Assists'] * 0.15 +
                team_stats['Steals'] * 0.15
            )
            
            team_stats['TeamRank'] = team_stats['TeamScore'].rank(ascending=False)
            
            return team_stats
        except Exception as e:
            logger.error(f"Failed to analyze team performance: {e}")
            return None

    def save_analysis(self, player_rankings, team_stats):
        try:
            os.makedirs(self.output_path, exist_ok=True)
            
            if player_rankings is not None:
                player_rankings.to_parquet(f"{self.output_path}/player_rankings.parquet")
                
            if team_stats is not None:
                team_stats.to_parquet(f"{self.output_path}/team_stats.parquet")
                
            logger.info("Analysis results saved successfully")
            return True
        except Exception as e:
            logger.error(f"Failed to save analysis results: {e}")
            return False

    def run(self):
        logger.info("Starting analysis pipeline")
        
        df = self.load_latest_data()
        if df is None:
            return False
            
        player_rankings = self.calculate_player_rankings(df)
        team_stats = self.analyze_team_performance(df)
        
        if self.save_analysis(player_rankings, team_stats):
            logger.info("Analysis pipeline completed successfully")
            return True
            
        logger.error("Analysis pipeline failed")
        return False

if __name__ == "__main__":
    analyzer = NBAAnalyzer()
    analyzer.run()
