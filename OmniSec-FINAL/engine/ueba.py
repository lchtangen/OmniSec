"""User & Entity Behavior Analytics"""
import json
from collections import defaultdict
from datetime import datetime

class UEBAEngine:
    def __init__(self):
        self.baselines = defaultdict(dict)
        self.anomalies = []
        
    def learn_behavior(self, entity, activity):
        if entity not in self.baselines:
            self.baselines[entity] = {'activities': [], 'normal_hours': set()}
        self.baselines[entity]['activities'].append(activity)
        
    def detect_anomaly(self, entity, activity):
        if entity not in self.baselines:
            return False
        baseline = self.baselines[entity]
        # Simple anomaly check
        hour = datetime.now().hour
        if hour < 6 or hour > 22:
            self.anomalies.append({'entity': entity, 'reason': 'unusual_time', 'activity': activity})
            return True
        return False
        
    def get_risk_score(self, entity):
        anomaly_count = len([a for a in self.anomalies if a['entity'] == entity])
        return min(anomaly_count * 10, 100)
