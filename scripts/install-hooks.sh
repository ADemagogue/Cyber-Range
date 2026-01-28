#!/usr/bin/env bash
# Install git pre-commit hooks for code quality checks.
# Run once: bash scripts/install-hooks.sh
set -euo pipefail

HOOKS_DIR="$(git rev-parse --show-toplevel)/.git/hooks"

cat > "$HOOKS_DIR/pre-commit" << 'HOOK'
#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
STAGED_SH=()
STAGED_DOCKER=()

while IFS= read -r file; do
  [[ "$file" == *.sh ]] && STAGED_SH+=("$file")
  [[ "$file" == *Dockerfile* ]] && STAGED_DOCKER+=("$file")
done < <(git diff --cached --name-only --diff-filter=ACMR)

ERRORS=0

# ── ShellCheck ───────────────────────────────────────────────
if command -v shellcheck &>/dev/null && [[ ${#STAGED_SH[@]} -gt 0 ]]; then
  echo "[hook] Running ShellCheck on ${#STAGED_SH[@]} file(s)..."
  for f in "${STAGED_SH[@]}"; do
    # Skip legacy script
    [[ "$f" == "rts/scripts/buildredteam.sh" ]] && continue
    shellcheck --severity=warning "$REPO_ROOT/$f" || ERRORS=1
  done
else
  if [[ ${#STAGED_SH[@]} -gt 0 ]]; then
    echo "[hook] shellcheck not found, skipping shell lint"
  fi
fi

# ── Hadolint ─────────────────────────────────────────────────
if command -v hadolint &>/dev/null && [[ ${#STAGED_DOCKER[@]} -gt 0 ]]; then
  echo "[hook] Running Hadolint on ${#STAGED_DOCKER[@]} file(s)..."
  for f in "${STAGED_DOCKER[@]}"; do
    hadolint --failure-threshold warning "$REPO_ROOT/$f" || ERRORS=1
  done
else
  if [[ ${#STAGED_DOCKER[@]} -gt 0 ]]; then
    echo "[hook] hadolint not found, skipping Dockerfile lint"
  fi
fi

# ── YAML check ───────────────────────────────────────────────
if git diff --cached --name-only --diff-filter=ACMR | grep -qE '\.ya?ml$'; then
  echo "[hook] Checking YAML syntax..."
  while IFS= read -r f; do
    python3 -c "import yaml; yaml.safe_load(open('$REPO_ROOT/$f'))" 2>/dev/null || {
      echo "  YAML error: $f"
      ERRORS=1
    }
  done < <(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.ya?ml$')
fi

# ── Secrets detection ────────────────────────────────────────
echo "[hook] Checking for secrets..."
if git diff --cached --name-only --diff-filter=ACMR | grep -qiE '\.env$|\.pem$|\.key$|\.p12$|credentials'; then
  echo "  WARNING: Potentially sensitive file staged. Review before committing."
  ERRORS=1
fi

if [[ $ERRORS -ne 0 ]]; then
  echo "[hook] Pre-commit checks failed."
  exit 1
fi

echo "[hook] All checks passed."
HOOK

chmod +x "$HOOKS_DIR/pre-commit"
echo "Pre-commit hook installed to $HOOKS_DIR/pre-commit"
