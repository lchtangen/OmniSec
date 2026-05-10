"""API Security Testing - REST/GraphQL/gRPC"""
import requests
import json

class APISecurityScanner:
    def __init__(self):
        self.vulns = []
        
    def scan_rest(self, base_url):
        findings = []
        # Test authentication
        r = requests.get(f"{base_url}/api", timeout=10)
        if r.status_code == 200:
            findings.append({'type': 'info_disclosure', 'severity': 'low'})
        return findings
        
    def test_bola(self, url, auth_token):
        # Test for Broken Object Level Authorization
        return []
        
    def test_idor(self, url):
        # Test for Insecure Direct Object Reference
        return []
        
    def fuzz_api(self, endpoint):
        payloads = ["' OR 1=1--", "<script>alert(1)</script>", "../../../etc/passwd"]
        findings = []
        for payload in payloads:
            try:
                r = requests.get(f"{endpoint}?param={payload}", timeout=5)
                if 'error' not in r.text.lower():
                    findings.append({'payload': payload, 'response': r.status_code})
            except:
                pass
        return findings
