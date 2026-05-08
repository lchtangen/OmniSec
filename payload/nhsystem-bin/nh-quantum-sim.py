#!/usr/bin/env python3
"""
nh-quantum-sim — Quantum Cryptography Simulator
Simulates quantum key distribution (BB84 protocol) for education
"""
import random
import sys

class QuantumSimulator:
    def __init__(self):
        self.bases = ['+', 'x']  # Rectilinear (+) and Diagonal (x)
        self.bits = ['0', '1']
        
    def generate_qubits(self, n=100):
        """Generate random qubits"""
        qubits = []
        for _ in range(n):
            bit = random.choice(self.bits)
            basis = random.choice(self.bases)
            qubits.append((bit, basis))
        return qubits
    
    def measure_qubits(self, qubits, bases):
        """Measure qubits with given bases"""
        results = []
        for (bit, qb), mb in zip(qubits, bases):
            if qb == mb:
                results.append(bit)  # Correct basis, get correct bit
            else:
                results.append(random.choice(self.bits))  # Wrong basis, random result
        return results
    
    def bb84_protocol(self, n=100):
        """Simulate BB84 QKD protocol"""
        print(f"══ BB84 Quantum Key Distribution Simulation ═")
        print("")
        
        # Alice generates qubits
        alice_bits_bases = self.generate_qubits(n)
        print(f"  Alice: Generated {n} qubits")
        
        # Bob chooses random bases
        bob_bases = [random.choice(self.bases) for _ in range(n)]
        print(f"  Bob: Selected {n} random bases")
        
        # Bob measures
        bob_results = self.measure_qubits(alice_bits_bases, bob_bases)
        print(f"  Bob: Measured qubits")
        
        # Sift key (keep only matching bases)
        sifted_key = []
        for i, ((bit, ab), bb) in enumerate(zip(alice_bits_bases, bob_bases)):
            if ab == bb:  # Same basis
                sifted_key.append(bit if ab == bb else random.choice(self.bits))
        
        print(f"  Sifted key length: {len(sifted_key)} bits")
        
        # Calculate QBER (Quantum Bit Error Rate)
        alice_key = [b[0] for b in alice_bits_bases if b[1] in [bob_bases[i] for i in range(n)]]
        errors = sum(1 for a, b in zip(alice_key[:len(sifted_key)], sifted_key) if a != b)
        qber = (errors / len(sifted_key)) * 100 if sifted_key else 0
        
        print(f"  QBER: {qber:.2f}%")
        
        if qber > 11:
            print("  ⚠ WARNING: High QBER - Possible eavesdropping!")
        else:
            print("  ✓ Key exchange secure")
        
        return sifted_key

if __name__ == "__main__":
    sim = QuantumSimulator()
    key = sim.bb84_protocol(int(sys.argv[1]) if len(sys.argv) > 1 else 100)
    print(f"\n  Generated key ({len(key)} bits): {''.join(key[:20])}...")
