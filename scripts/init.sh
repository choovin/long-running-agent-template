#!/bin/bash
# =============================================================================
# Initialization Script for Long-Running Agent Project
# =============================================================================
# This script sets up the complete development environment for the project.
# Run this once when first setting up the project, or after major changes.
# =============================================================================

set -e  # Exit on error
set -o pipefail  # Exit on pipe failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# Environment Checks
# =============================================================================

check_dependencies() {
    log_info "Checking dependencies..."

    local missing=()

    # Check for Node.js
    if ! command -v node &> /dev/null; then
        missing+=("node")
    else
        log_success "Node.js $(node --version) found"
    fi

    # Check for npm
    if ! command -v npm &> /dev/null; then
        missing+=("npm")
    else
        log_success "npm $(npm --version) found"
    fi

    # Check for git
    if ! command -v git &> /dev/null; then
        missing+=("git")
    else
        log_success "git $(git --version | awk '{print $3}') found"
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing[*]}"
        log_info "Please install missing dependencies and try again."
        exit 1
    fi
}

# =============================================================================
# Environment Setup
# =============================================================================

setup_environment() {
    log_info "Setting up environment..."

    cd "$PROJECT_ROOT"

    # Create .env file from .env.example if it doesn't exist
    if [ -f ".env.example" ] && [ ! -f ".env" ]; then
        log_info "Creating .env file from .env.example"
        cp .env.example .env
        log_warning "Please update .env with your actual values"
    fi

    # Create necessary directories
    log_info "Creating project directories..."
    mkdir -p .agent/state/checkpoints
    mkdir -p progress/session_logs
    mkdir -p logs

    log_success "Environment directories created"
}

# =============================================================================
# Dependency Installation
# =============================================================================

install_dependencies() {
    log_info "Installing dependencies..."

    cd "$PROJECT_ROOT"

    if [ -f "package.json" ]; then
        npm install
        log_success "Node dependencies installed"
    elif [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
        log_success "Python dependencies installed"
    elif [ -f "go.mod" ]; then
        go mod download
        log_success "Go dependencies installed"
    elif [ -f "Cargo.toml" ]; then
        cargo fetch
        log_success "Rust dependencies installed"
    else
        log_warning "No dependency file found. Skipping dependency installation."
    fi
}

# =============================================================================
# Database Setup
# =============================================================================

setup_database() {
    log_info "Setting up database..."

    cd "$PROJECT_ROOT"

    # Check for database setup scripts
    if [ -f "scripts/db_setup.sh" ]; then
        ./scripts/db_setup.sh
        log_success "Database setup complete"
    elif [ -f "prisma/schema.prisma" ]; then
        npx prisma generate
        npx prisma migrate dev --name init
        log_success "Prisma database setup complete"
    else
        log_info "No database setup required"
    fi
}

# =============================================================================
# Git Setup
# =============================================================================

setup_git() {
    log_info "Setting up git repository..."

    cd "$PROJECT_ROOT"

    if [ ! -d ".git" ]; then
        git init
        log_success "Git repository initialized"

        # Create initial commit if there are files
        if [ -n "$(git status --porcelain)" ]; then
            git add .
            git commit -m "chore: initial project setup

- Project structure created
- Configuration files added
- Feature list generated

Co-Authored-By: Initializer Agent <noreply@anthropic.com>"
            log_success "Initial commit created"
        fi
    else
        log_info "Git repository already exists"
    fi
}

# =============================================================================
# Verification
# =============================================================================

verify_setup() {
    log_info "Verifying setup..."

    cd "$PROJECT_ROOT"

    local errors=0

    # Check essential files
    local essential_files=(
        ".agent/config.yaml"
        "features/feature_list.json"
        "progress/claude-progress.md"
        "scripts/init.sh"
        "scripts/start_dev.sh"
    )

    for file in "${essential_files[@]}"; do
        if [ -f "$file" ]; then
            log_success "Found: $file"
        else
            log_error "Missing: $file"
            ((errors++))
        fi
    done

    # Check scripts are executable
    for script in scripts/*.sh; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            log_success "Made executable: $script"
        fi
    done

    if [ $errors -eq 0 ]; then
        log_success "Setup verification passed!"
        return 0
    else
        log_error "Setup verification failed with $errors errors"
        return 1
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo ""
    echo "=========================================="
    echo "  Long-Running Agent Project Initialization"
    echo "=========================================="
    echo ""

    check_dependencies
    setup_environment
    install_dependencies
    setup_database
    setup_git
    verify_setup

    echo ""
    echo "=========================================="
    log_success "Initialization complete!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "  1. Review and update .env file (if applicable)"
    echo "  2. Run ./scripts/start_dev.sh to start development"
    echo "  3. Run ./scripts/test_e2e.sh to verify functionality"
    echo ""
}

# Run main function
main "$@"