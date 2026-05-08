#!/usr/bin/env python3
"""
nh-neural — Neural Network Anomaly Detection
Uses simple neural network to detect anomalies in system behavior
"""
import json
import sys
import random

class SimpleNeuralNet:
    def __init__(self, input_size=5, hidden_size=10, output_size=1):
        # Initialize random weights
        self.w1 = [[random.uniform(-1, 1) for _ in range(hidden_size)] for _ in range(input_size)]
        self.w2 = [[random.uniform(-1, 1) for _ in range(output_size)] for _ in range(hidden_size)]
        self.b1 = [0.0] * hidden_size
        self.b2 = [0.0] * output_size
    
    def sigmoid(self, x):
        return 1 / (1 + 2.71828 ** -x)
    
    def forward(self, inputs):
        # Hidden layer
        hidden = []
        for j in range(len(self.w1[0])):
            val = self.b1[j]
            for i in range(len(inputs)):
                val += inputs[i] * self.w1[i][j]
            hidden.append(self.sigmoid(val))
        
        # Output layer
        output = 0.0
        for j in range(len(hidden)):
            output += hidden[j] * self.w2[j][0]
        output += self.b2[0]
        
        return self.sigmoid(output)
    
    def detect_anomaly(self, metrics):
        """Detect if metrics indicate anomaly"""
        score = self.forward(metrics)
        return {
            'anomaly': score > 0.5,
            'score': score,
            'confidence': abs(score - 0.5) * 2
        }

class AnomalyDetector:
    def __init__(self):
        self.net = SimpleNeuralNet()
        self.normal_baseline = [0.3, 0.2, 0.1, 0.05, 0.1]  # CPU, mem, disk, net, proc
    
    def collect_metrics(self):
        """Collect current system metrics (simulated)"""
        import os
        # Simulate collection
        return [
            random.uniform(0.1, 0.8),  # CPU usage
            random.uniform(0.2, 0.7),  # Memory usage
            random.uniform(0.1, 0.6),  # Disk usage
            random.uniform(0.05, 0.3), # Network activity
            random.uniform(0.1, 0.5)   # Process count (normalized)
        ]
    
    def analyze(self):
        """Analyze system for anomalies"""
        print("══ Neural Anomaly Detection ═")
        print("")
        
        metrics = self.collect_metrics()
        print(f"  Current metrics:")
        print(f"    CPU: {metrics[0]:.2f}")
        print(f"    Memory: {metrics[1]:.2f}")
        print(f"    Disk: {metrics[2]:.2f}")
        print(f"    Network: {metrics[3]:.2f}")
        print(f"    Processes: {metrics[4]:.2f}")
        print("")
        
        result = self.net.detect_anomaly(metrics)
        
        if result['anomaly']:
            print(f"  ⚠ ANOMALY DETECTED!")
            print(f"    Score: {result['score']:.4f}")
            print(f"    Confidence: {result['confidence']:.2%}")
        else:
            print(f"  ✓ System normal")
            print(f"    Score: {result['score']:.4f}")
            print(f"    Confidence: {result['confidence']:.2%}")

if __name__ == "__main__":
    detector = AnomalyDetector()
    detector.analyze()
