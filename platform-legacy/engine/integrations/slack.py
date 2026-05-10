"""Slack Integration"""
import requests

class SlackIntegration:
    def __init__(self, webhook_url):
        self.webhook = webhook_url
        
    def send_alert(self, message, severity="info"):
        payload = {"text": f"[{severity.upper()}] {message}"}
        try:
            requests.post(self.webhook, json=payload, timeout=10)
            return True
        except:
            return False
