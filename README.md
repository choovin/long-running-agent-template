# Long-Running Agent System Template

A production-ready template for building AI agents that work effectively across multiple context windows, based on Anthropic's research on effective harnesses for long-running agents.

## One-Line Install

```bash
mkdir -p ~/.claude/skills && git clone --depth 1 https://github.com/choovin/long-running-agent-template.git /tmp/lra-template && cp -r /tmp/lra-template/skills/long-running-agent ~/.claude/skills/ && rm -rf /tmp/lra-template && echo "✅ Installed!"
```

After installation, say in Claude Code: `Build an app using long-running agent mode`

---

## Features

- **Project Template**: Complete project structure with feature management, progress tracking, and testing infrastructure
- **CLI Automation**: `dev-agent.py` tool for managing workflow via command line
- **Dual Execution Modes**:
  - **Mode A (Interactive)**: Claude implements features directly, better visibility, MCP tools work
  - **Mode B (Autopilot)**: Fully autonomous execution with parallel support
- **Team Mode**: Parallel development with git worktree isolation
- **YAML Configuration**: Flexible agent configuration via `.agent/config.yaml`
- **Complete Testing Framework**: Unit tests, E2E tests, and browser automation

## Core Concepts

This template implements a two-part solution:

1. **Initializer Agent** - Sets up the environment on the first run
2. **Coding Agent** - Makes incremental progress in every session while leaving clear artifacts

## Project Structure

```
.
├── .agent/                    # Agent configuration and state
│   ├── config.yaml           # Agent configuration
│   ├── prompts/              # Agent prompts
│   │   ├── initializer.md    # Initial session prompt
│   │   └── coding.md         # Incremental progress prompt
│   └── state/                # Runtime state (git-ignored)
│       ├── session.json      # Current session info
│       └── checkpoints/      # Session checkpoints
├── features/                  # Feature management
│   ├── feature_list.json     # Comprehensive feature requirements
│   └── feature_schema.json   # JSON schema for features
├── progress/                  # Progress tracking
│   ├── claude-progress.md    # Human-readable progress log
│   └── session_logs/         # Detailed session logs
├── scripts/                   # Automation scripts
│   ├── dev-agent.py          # CLI tool for workflow management
│   ├── init.sh               # Environment initialization
│   ├── start_dev.sh          # Start development server
│   ├── test_e2e.sh           # End-to-end testing
│   └── checkpoint.sh         # Create session checkpoint
├── templates/                 # Workflow templates
│   └── AGENTS.md             # Agent workflow template
├── tests/                     # Test suites
│   ├── e2e/                  # End-to-end tests
│   ├── unit/                 # Unit tests
│   └── integration/          # Integration tests
├── src/                       # Source code
│   └── ...                   # Your application code
├── docs/                      # Documentation
│   ├── architecture.md       # System architecture
│   ├── agent-workflow.md     # Agent workflow guide
│   └── troubleshooting.md    # Common issues and solutions
├── .gitignore
├── CLAUDE.md                  # Instructions for Claude Code
└── README.md
```

## Quick Start

### 1. Initialize the Project

```bash
# Run the initializer script
./scripts/init.sh
```

### 2. Choose Your Mode

#### Mode A: Interactive (Recommended)

Best for visibility, MCP tools work, no extra permissions needed.

```bash
# Check status
python3 scripts/dev-agent.py status

# Get next feature
python3 scripts/dev-agent.py next

# After implementing and testing, mark complete
python3 scripts/dev-agent.py complete F001
```

#### Mode B: Autopilot

Fully autonomous execution, runs multiple features automatically.

```bash
# Start autonomous development
python3 scripts/dev-agent.py run

# Run with options
python3 scripts/dev-agent.py run --max-features 10    # Limit to 10 features
python3 scripts/dev-agent.py run --parallel 3         # Run 3 features in parallel
python3 scripts/dev-agent.py run --timeout 3600       # 1 hour per feature
```

## CLI Commands Reference

| Command | Description |
|---------|-------------|
| `python3 scripts/dev-agent.py status` | Show progress summary |
| `python3 scripts/dev-agent.py next` | Get next feature to implement |
| `python3 scripts/dev-agent.py find-parallel` | Show parallelizable features |
| `python3 scripts/dev-agent.py complete <id>` | Mark feature as passing |
| `python3 scripts/dev-agent.py skip <id> "reason"` | Skip a feature |
| `python3 scripts/dev-agent.py regression` | Pick features to re-verify |
| `python3 scripts/dev-agent.py log ...` | Log structured progress |
| `python3 scripts/dev-agent.py run` | Start autonomous loop |

## Key Components

### Feature List (`features/feature_list.json`)

```json
{
  "project": "Your Project Name",
  "version": "1.0.0",
  "features": [
    {
      "id": "F001",
      "category": "functional",
      "priority": "high",
      "description": "Feature description",
      "steps": [
        "Step 1: Navigate to X",
        "Step 2: Perform Y",
        "Step 3: Verify Z"
      ],
      "acceptance_criteria": [
        "Criteria 1",
        "Criteria 2"
      ],
      "dependencies": [],
      "passes": false,
      "last_tested": null,
      "skip_reason": null
    }
  ]
}
```

### Progress File (`progress/claude-progress.md`)

Tracks all work done across sessions:

```markdown
# Progress Log

## Session 2024-01-15-001
- Started: 2024-01-15 10:00
- Duration: 2 hours
- Features worked on: F001, F002
- Status: F001 complete, F002 in progress
- Commits: abc123, def456
- Notes: Basic authentication working
```

### Configuration (`.agent/config.yaml`)

```yaml
agent:
  model: "claude-opus-4-5"
  max_context_tokens: 200000

execution:
  mode: "interactive"  # interactive | autopilot
  max_turns_per_feature: 150
  timeout_per_feature: 1800

team_mode:
  enabled: false
  max_parallel: 3

testing:
  e2e_required: true
  browser_automation: true
```

## Team Mode (Parallel Development)

When multiple independent features are available, enable Team Mode for parallel development:

```bash
# Check for parallelizable features
python3 scripts/dev-agent.py find-parallel

# Run in parallel
python3 scripts/dev-agent.py run --parallel 3
```

Each parallel session gets its own git worktree, ensuring isolated development.

## Testing Strategy

### Browser Automation Testing

Uses Playwright/Puppeteer for end-to-end testing:

```javascript
// tests/e2e/basic_flow.spec.js
test('User can send a message', async ({ page }) => {
  await page.goto('/');
  await page.fill('[data-testid="message-input"]', 'Hello');
  await page.click('[data-testid="send-button"]');
  await expect(page.locator('.response')).toBeVisible();
});
```

### Self-Verification Protocol

Before marking any feature as "passing":

1. Run unit tests: `npm test`
2. Run e2e tests: `npm run test:e2e`
3. Manual browser verification
4. Check for regressions

## Failure Modes and Solutions

| Problem | Solution |
|---------|----------|
| Agent declares victory too early | Feature list with explicit tests |
| Environment left in buggy state | Git commits + progress notes |
| Features marked done prematurely | Self-verification protocol |
| Time wasted figuring out setup | init.sh script |

## Best Practices

1. **Incremental Progress** - One feature at a time
2. **Clean State** - Always commit working code
3. **Documentation** - Update progress every session
4. **Testing** - Verify before marking complete
5. **Recovery** - Use git to revert bad changes

## Integration with Claude Code

This template includes a `CLAUDE.md` file with instructions for Claude Code to follow the long-running agent workflow automatically.

## References

- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Agent SDK](https://github.com/anthropics/claude-agent-sdk)
- [Claude 4 Prompting Guide](https://docs.anthropic.com/en/docs/prompting-guide)

## License

MIT