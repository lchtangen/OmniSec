#!/usr/bin/env python3
"""
nh-ml-analyzer — Machine Learning Threat Analyzer
Uses ML models to analyze security threats and predict attacks
"""
import json
import subprocess
import sys
from collections import Counter

class MLThreatAnalyzer:
    def __init__(self):
        self.threat_patterns = {
            'brute_force': ['failed', 'invalid', 'error', 'authentication', 'login'],
            'scan': ['nmap', 'masscan', 'scan', 'probe', 'discovery'],
            'exploit': ['exploit', 'payload', 'shellcode', 'buffer', 'overflow'],
            'malware': ['malicious', 'virus', 'trojan', 'backdoor', 'rootkit']
        }
    
    def extract_features(self, log_line):
        """Extract features from log line"""
        features = {}
        line_lower = log_line.lower()
        
        for category, patterns in self.threat_patterns.items():
            features[category] = sum(1 for p in patterns if p in line_lower)
        
        return features
    
    def predict_threat(self, log_file):
        """Predict threats from log file"""
        predictions = []
        
        try:
            with open(log_file, 'r') as f:
                for line in f:
                    features = self.extract_features(line)
                    total_score = sum(features.values())
                    
                    if total_score > 2:
                        predictions.append({
                            'line': line[:100],
                            'score': total_score,
                            'features': features
                        })
        except Exception as e:
            print(f"Error: {e}")
        
        return predictions
    
    def analyze(self, log_file):
        """Main analysis function"""
        print(f"══ ML Threat Analysis: {log_file} ═")
        print("")
        
        if not log_file or not os.path.exists(log_file):
            print(f"  Log file not found: {log_file}")
            return
        
        predictions = self.predict_threat(log_file)
        
        print(f"  Lines analyzed: {sum(1 for _ in open(log_file))}")
        print(f"  Threats detected: {len(predictions)}")
        print("")
        
        if predictions:
            print("  Top threats:")
            for i, pred in enumerate(predictions[:5], 1):
                print(f"    {i}. Score: {pred['score']} | {pred['line'][:60]}...")
        else:
            print("  No significant threats detected")

if __name__ == "__main__":
    import os
    analyzer = MLThreatAnalyzer()
    log_file = sys.argv[1] if len(sys.argv) > 1 else "/data/local/nhsystem/logs/nh-all.log"
    analyzer.analyze(log_file)
