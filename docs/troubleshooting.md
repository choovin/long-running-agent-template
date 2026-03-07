# Troubleshooting Guide

Common issues and their solutions when working with the Long-Running Agent System.

## Setup Issues

### "Cannot find module" errors

**Problem**: Node modules are not installed.

**Solution**:
```bash
./scripts/init.sh
# Or manually:
npm install
```

### "Permission denied" when running scripts

**Problem**: Scripts are not executable.

**Solution**:
```bash
chmod +x scripts/*.sh
```

### "Port 3000 is already in use"

**Problem**: Another process is using the port.

**Solution**:
```bash
# Find and kill the process
lsof -i :3000
kill -9 <PID>

# Or use a different port
PORT=3001 npm run dev
```

## Test Issues

### E2E tests fail with "browser not found"

**Problem**: Playwright browsers are not installed.

**Solution**:
```bash
npx playwright install
```

### Tests pass locally but fail in CI

**Problem**: Environment differences.

**Solution**:
1. Check `BASE_URL` environment variable
2. Ensure all dependencies are installed
3. Check for hardcoded localhost URLs
4. Verify CI has sufficient resources

### Smoke tests fail after implementing a feature

**Problem**: Feature introduced a regression.

**Solution**:
1. Run `git diff HEAD~1` to see changes
2. Revert the commit: `git revert HEAD`
3. Fix the issue before continuing
4. Never mark a feature complete with failing smoke tests

## Git Issues

### "Your branch is ahead of origin/main"

**Problem**: Local commits not pushed.

**Solution**:
```bash
git push origin main
```

### "Uncommitted changes" when trying to switch branches

**Problem**: Working directory is not clean.

**Solution**:
```bash
# Option 1: Commit changes
git add -A
git commit -m "wip: work in progress"

# Option 2: Stash changes
git stash

# Option 3: Discard changes (careful!)
git checkout -- .
```

### "Merge conflicts" after pull

**Problem**: Conflicting changes with remote.

**Solution**:
1. Open conflicted files
2. Look for `<<<<<<<` markers
3. Resolve conflicts manually
4. Run tests before committing

## Feature Issues

### Feature marked as passing but doesn't work

**Problem**: Insufficient testing when marking feature complete.

**Solution**:
1. Mark feature as failing:
   ```bash
   jq '(.features[] | select(.id == "F00X")).passes = false' features/feature_list.json > tmp.json
   mv tmp.json features/feature_list.json
   ```
2. Re-implement and test properly
3. Follow verification protocol strictly

### Cannot find next feature to work on

**Problem**: All visible features have unmet dependencies.

**Solution**:
```bash
# Find features with all dependencies met
cat features/feature_list.json | jq '
  .features[] |
  select(.passes == false) |
  select(.dependencies | length == 0 or all(. as $dep | .features[] | select(.id == $dep) | .passes))
'
```

### Feature is too complex to complete in one session

**Problem**: Feature is not atomic enough.

**Solution**:
1. Split the feature into smaller features
2. Update feature_list.json with new features
3. Work on smaller features one at a time

## Agent Issues

### Agent keeps working on the same feature

**Problem**: Agent isn't reading the progress file correctly.

**Solution**:
1. Ensure progress file is updated after each session
2. Add explicit notes about what's done
3. Check that git commits are being made

### Agent skips the orientation phase

**Problem**: Agent doesn't follow the workflow.

**Solution**:
1. Re-read CLAUDE.md
2. Ensure prompts are correct
3. Use explicit instructions to start with orientation

### Agent modifies feature list incorrectly

**Problem**: Agent changes feature descriptions instead of just status.

**Solution**:
1. Use JSON format (more resistant to modification)
2. Add explicit instructions in prompt
3. Use jq for updates (preserves structure)

## Performance Issues

### Tests are slow

**Problem**: Too many tests or inefficient tests.

**Solution**:
1. Run specific tests: `./scripts/test_e2e.sh --feature F00X`
2. Use smoke tests for quick verification
3. Optimize test database queries

### Development server is slow

**Problem**: Too many dependencies or large codebase.

**Solution**:
1. Check for unnecessary dependencies
2. Use production build for testing
3. Consider splitting the application

## Getting Help

If you encounter issues not covered here:

1. Check the [Architecture](./architecture.md) documentation
2. Review the [Agent Workflow](./agent-workflow.md) guide
3. Search for similar issues in project history
4. Create a detailed issue report with:
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details
   - Relevant logs