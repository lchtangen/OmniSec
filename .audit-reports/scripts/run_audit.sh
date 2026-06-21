#!/bin/bash

# Comprehensive Workspace Audit Script

AUDIT_DIR="/home/arch/projects/multi-platform/.audit-reports"
WORKSPACE_ROOT="/home/arch/projects/multi-platform"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="$AUDIT_DIR/data/$TIMESTAMP"

mkdir -p "$REPORT_DIR"

echo "=== Starting Comprehensive Workspace Audit ==="
echo "Timestamp: $TIMESTAMP"
echo "Workspace: $WORKSPACE_ROOT"
echo ""

# PHASE 1: Directory Statistics
echo "[1/7] Generating directory statistics..."
{
  echo "# Directory Statistics"
  echo "Generated: $(date)"
  echo ""
  echo "| Directory | Files | Subdirs | Size |"
  echo "|-----------|-------|---------|------|"
  
  find "$WORKSPACE_ROOT" -maxdepth 1 -type d ! -name '.audit*' ! -name '.git*' | sort | while read dir; do
    if [ -d "$dir" ]; then
      dirname=$(basename "$dir")
      filecount=$(find "$dir" -type f 2>/dev/null | wc -l)
      dircount=$(find "$dir" -type d 2>/dev/null | wc -l)
      size=$(du -sh "$dir" 2>/dev/null | cut -f1)
      printf "| %-30s | %6d | %7d | %6s |\n" "$dirname" "$filecount" "$dircount" "$size"
    fi
  done
} > "$REPORT_DIR/01_DIRECTORY_STATISTICS.md"
echo "[✓] Complete"

# PHASE 2A: File Inventory
echo "[2/7] Building file inventory..."
{
  echo "# File Type Distribution"
  echo "Generated: $(date)"
  echo ""
  echo "| Extension | Count |"
  echo "|-----------|-------|"
  
  find "$WORKSPACE_ROOT" -type f ! -path '*/.git/*' ! -path '*/node_modules/*' ! -path '*/.audit*' 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -40 | awk '{printf "| %-20s | %6d |\n", "."$2, $1}'
} > "$REPORT_DIR/02_FILE_INVENTORY.md"
echo "[✓] Complete"

# PHASE 2B: Security Scanning
echo "[3/7] Security scanning..."
{
  echo "# Security Audit"
  echo "Generated: $(date)"
  echo ""
  echo "## Files with Suspicious Names (potential secrets)"
  find "$WORKSPACE_ROOT" -type f \( -name "*.env*" -o -name "*secret*" -o -name "*key*" -o -name "*credential*" -o -name "*password*" \) ! -path '*/.git/*' ! -path '*/node_modules/*' 2>/dev/null | head -50 | sed 's|^'$WORKSPACE_ROOT'/|  |'
  
  echo ""
  echo "## World-Writable Files (SECURITY RISK)"
  find "$WORKSPACE_ROOT" -type f -perm -002 ! -path '*/.git/*' 2>/dev/null | head -20 | sed 's|^'$WORKSPACE_ROOT'/|  |' || echo "  None found"
  
  echo ""
  echo "## Shell Scripts Analysis"
  echo "Total: $(find "$WORKSPACE_ROOT" -type f -name "*.sh" ! -path '*/.git/*' 2>/dev/null | wc -l)"
  
} > "$REPORT_DIR/03_SECURITY_SCAN.md"
echo "[✓] Complete"

# PHASE 2B.2: Dependency Manifest
echo "[4/7] Indexing dependencies..."
{
  echo "# Dependency Manifest"
  echo "Generated: $(date)"
  echo ""
  
  py_count=$(find "$WORKSPACE_ROOT" -name "pyproject.toml" ! -path '*/.git/*' ! -path '*/node_modules/*' 2>/dev/null | wc -l)
  req_count=$(find "$WORKSPACE_ROOT" -name "requirements*.txt" ! -path '*/.git/*' ! -path '*/node_modules/*' 2>/dev/null | wc -l)
  pkg_count=$(find "$WORKSPACE_ROOT" -name "package.json" ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null | wc -l)
  docker_count=$(find "$WORKSPACE_ROOT" -name "Dockerfile" ! -path '*/.git/*' 2>/dev/null | wc -l)
  go_count=$(find "$WORKSPACE_ROOT" -name "go.mod" ! -path '*/.git/*' 2>/dev/null | wc -l)
  
  echo "| Config Type | Count |"
  echo "|-------------|-------|"
  echo "| pyproject.toml | $py_count |"
  echo "| requirements.txt | $req_count |"
  echo "| package.json | $pkg_count |"
  echo "| Dockerfile | $docker_count |"
  echo "| go.mod | $go_count |"
  echo ""
  echo "## Python Projects"
  find "$WORKSPACE_ROOT" -name "pyproject.toml" ! -path '*/.git/*' ! -path '*/node_modules/*' 2>/dev/null | sed 's|^'$WORKSPACE_ROOT'/|  |'
  
  echo ""
  echo "## Node.js Projects"
  find "$WORKSPACE_ROOT" -name "package.json" ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null | sed 's|^'$WORKSPACE_ROOT'/|  |'
  
  echo ""
  echo "## Docker Containers"
  find "$WORKSPACE_ROOT" -name "Dockerfile" ! -path '*/.git/*' 2>/dev/null | sed 's|^'$WORKSPACE_ROOT'/|  |'
  
} > "$REPORT_DIR/04_DEPENDENCIES_MANIFEST.md"
echo "[✓] Complete"

# PHASE 3: Documentation Audit
echo "[5/7] Documentation audit..."
{
  echo "# Documentation Audit"
  echo "Generated: $(date)"
  echo ""
  
  readme_count=$(find "$WORKSPACE_ROOT" -maxdepth 3 -name "README.md" ! -path '*/.git/*' ! -path '*/node_modules/*' 2>/dev/null | wc -l)
  changelog_count=$(find "$WORKSPACE_ROOT" -maxdepth 3 -name "CHANGELOG.md" ! -path '*/.git/*' 2>/dev/null | wc -l)
  license_count=$(find "$WORKSPACE_ROOT" -maxdepth 3 \( -name "LICENSE*" -o -name "COPYING*" \) ! -path '*/.git/*' 2>/dev/null | wc -l)
  
  echo "| Documentation | Count |"
  echo "|----------------|-------|"
  echo "| README files | $readme_count |"
  echo "| CHANGELOG files | $changelog_count |"
  echo "| LICENSE files | $license_count |"
  
} > "$REPORT_DIR/05_DOCUMENTATION_AUDIT.md"
echo "[✓] Complete"

# PHASE 4: License Compliance
echo "[6/7] License compliance..."
{
  echo "# License Compliance"
  echo "Generated: $(date)"
  echo ""
  echo "## License Distribution"
  find "$WORKSPACE_ROOT" -maxdepth 3 \( -name "LICENSE*" -o -name "COPYING*" \) ! -path '*/.git/*' 2>/dev/null | sed 's|^'$WORKSPACE_ROOT'/|  |'
  
} > "$REPORT_DIR/06_LICENSE_COMPLIANCE.md"
echo "[✓] Complete"

# PHASE 5: Project Structure
echo "[7/7] Project structure validation..."
{
  echo "# Project Structure Validation"
  echo "Generated: $(date)"
  echo ""
  echo "## Active Development Projects"
  
  find "$WORKSPACE_ROOT" -name "pyproject.toml" ! -path '*/.git/*' 2>/dev/null | head -15 | while read pyproj; do
    dir=$(dirname "$pyproj")
    relative_dir=$(echo "$dir" | sed 's|^'$WORKSPACE_ROOT'/||')
    has_tests=$([ -d "$dir/tests" ] || [ -d "$dir/test" ] && echo "✓" || echo "✗")
    has_readme=$([ -f "$dir/README.md" ] && echo "✓" || echo "✗")
    echo "  - $relative_dir (Tests: $has_tests, README: $has_readme)"
  done
  
} > "$REPORT_DIR/07_STRUCTURE_VALIDATION.md"
echo "[✓] Complete"

# Create manifest
{
  echo "# Audit Manifest"
  echo "Timestamp: $TIMESTAMP"
  echo "Workspace: $WORKSPACE_ROOT"
  echo ""
  echo "## Reports Generated"
  ls -1 "$REPORT_DIR" | grep "^[0-9]"
} > "$REPORT_DIR/00_MANIFEST.md"

echo ""
echo "=== Audit Complete ==="
echo "Reports saved to: $REPORT_DIR"
echo ""
ls -lh "$REPORT_DIR" | tail -10
