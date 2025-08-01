#!/bin/bash

# Claude Code Optimization Guide Auto-installer
# Usage: curl -sSL https://raw.githubusercontent.com/your-repo/claude-code-guide/main/install.sh | bash

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored text
print_color() {
    printf "${1}${2}${NC}\n"
}

print_header() {
    echo
    print_color $BLUE "=================================================="
    print_color $BLUE "  Claude Code Optimization Guide - Auto Installer"
    print_color $BLUE "==================================================
    echo
}

print_success() {
    print_color $GREEN "✅ $1"
}

print_error() {
    print_color $RED "❌ $1"
}

print_warning() {
    print_color $YELLOW "⚠️  $1"
}

print_info() {
    print_color $BLUE "ℹ️  $1"
}

# Check if in project directory
check_project_directory() {
    if [[ -f "package.json" ]] || [[ -f "pom.xml" ]] || [[ -f "Cargo.toml" ]] || [[ -f "go.mod" ]] || [[ -f "requirements.txt" ]] || [[ -f "composer.json" ]]; then
        return 0
    else
        return 1
    fi
}

# Create global configuration directory
setup_global_config() {
    local config_dir="$HOME/.claude-code-guide"
    
    print_info "Setting up global configuration directory: $config_dir"
    
    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir"
        print_success "Created global configuration directory"
    else
        print_info "Global configuration directory already exists"
    fi
    
    # Download global template files
    local files=("ClaudeCodeOptimizationGuide.md" "PromptTemplates.md" "QuickStartGuide.md" "README.md")
    
    for file in "${files[@]}"; do
        if [[ ! -f "$config_dir/$file" ]] || [[ "$1" == "--force" ]]; then
            # Should download from your GitHub repo, temporarily using local copy
            if [[ -f "./$file" ]]; then
                cp "./$file" "$config_dir/"
                print_success "Copied $file to global configuration"
            else
                print_warning "Cannot find $file, please download manually"
            fi
        fi
    done
    
    # Create global CLAUDE configuration template
    cat > "$config_dir/CLAUDE-template.md" << 'EOF'
# Claude Code 全域配置模板

## 🔧 個人偏好設定
- **代碼風格**: [你的偏好，如 functional, OOP]
- **命名規範**: [camelCase, snake_case, PascalCase]
- **錯誤處理**: 總是包含適當的錯誤處理
- **測試偏好**: [Jest, Mocha, pytest 等]

## 🛠️ 常用技術棧
- **前端**: [React, Vue, Angular]
- **後端**: [Node.js, Python, Java, Go]
- **數據庫**: [PostgreSQL, MongoDB, Redis]
- **部署**: [Docker, AWS, Vercel]

## 🚫 全域避免事項
- 不要使用過時的語法
- 不要創建不必要的複雜結構
- 不要忽略錯誤處理
- 不要使用 var 聲明（JavaScript）

## 📝 個人常用模板
[在這裡添加你的個人化模板]

---
> 這是全域配置，會被所有專案繼承
EOF

    print_success "Created global configuration template"
    
    echo "export CLAUDE_CODE_GUIDE_PATH=\"$config_dir\"" >> "$HOME/.bashrc" 2>/dev/null || true
    echo "export CLAUDE_CODE_GUIDE_PATH=\"$config_dir\"" >> "$HOME/.zshrc" 2>/dev/null || true
    
    export CLAUDE_CODE_GUIDE_PATH="$config_dir"
}

# Install to current project
install_to_project() {
    local project_dir=$(pwd)
    local config_dir="$HOME/.claude-code-guide"
    
    print_info "Installing Claude Code guide to current project: $project_dir"
    
    # Detect project type
    local project_type="generic"
    if [[ -f "package.json" ]]; then
        project_type="javascript"
    elif [[ -f "pom.xml" ]]; then
        project_type="java"
    elif [[ -f "Cargo.toml" ]]; then
        project_type="rust"
    elif [[ -f "go.mod" ]]; then
        project_type="go"
    elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        project_type="python"
    fi
    
    print_info "Detected project type: $project_type"
    
    # Copy core files
    local core_files=("ClaudeCodeOptimizationGuide.md" "PromptTemplates.md" "QuickStartGuide.md")
    
    for file in "${core_files[@]}"; do
        if [[ -f "$config_dir/$file" ]]; then
            cp "$config_dir/$file" "$project_dir/"
            print_success "Installed $file"
        else
            print_error "Cannot find $file in global configuration"
        fi
    done
    
    # Generate project-specific CLAUDE.md
    generate_project_claude_md "$project_type" "$project_dir"
    
    # Create .claudeignore file
    create_claudeignore "$project_dir"
    
    print_success "安裝完成！"
    print_info "請編輯 CLAUDE.md 填入你的專案特定信息"
}

# Generate project-specific CLAUDE.md
generate_project_claude_md() {
    local project_type=$1
    local project_dir=$2
    local project_name=$(basename "$project_dir")
    
    # Read global configuration
    local global_config=""
    if [[ -f "$HOME/.claude-code-guide/CLAUDE-template.md" ]]; then
        global_config=$(cat "$HOME/.claude-code-guide/CLAUDE-template.md")
    fi
    
    cat > "$project_dir/CLAUDE.md" << EOF
# Claude Code 專案記憶文件

## 📋 專案基本信息
- **專案名稱**: $project_name
- **專案類型**: $project_type
- **技術棧**: [請填入具體技術棧]
- **架構模式**: [MVC, 微服務, JAMstack 等]

## 🛠️ 開發環境設定
$(generate_dev_commands "$project_type")

## 📁 專案結構
$(generate_project_structure "$project_type")

## 🎯 Claude Code 互動原則

### 每次互動必須包含：
\`\`\`
參考專案中的 ClaudeCodeOptimizationGuide.md 和 CLAUDE.md，請遵循 token 節省原則。
\`\`\`

### 我的偏好設定：
- **輸出格式**: 只要代碼，不需要解釋 (除非特別要求)
- **代碼風格**: [請根據專案調整]
- **命名規範**: [請根據專案調整]
- **錯誤處理**: 總是包含 try-catch 和適當的錯誤處理

$(generate_tech_preferences "$project_type")

## 🚫 避免的做法
- 不要使用過時的語法或模式
- 不要創建不必要的複雜結構
- 不要忽略錯誤處理

---

$global_config

---

## 🔄 使用本文件的方法

### 方法 1: 直接引用
\`\`\`
根據 CLAUDE.md 的設定，[你的具體需求]
\`\`\`

### 方法 2: 結合優化指南
\`\`\`
參考 CLAUDE.md 和 ClaudeCodeOptimizationGuide.md，[你的具體需求]
\`\`\`

---

**💡 提示**: 定期更新這個文件，讓 Claude Code 更好地理解你的專案需求！
EOF

    print_success "Generated project-specific CLAUDE.md"
}

# Generate development commands based on project type
generate_dev_commands() {
    case $1 in
        "javascript")
            echo "- **開發指令**: \`npm run dev\` 或 \`yarn dev\`"
            echo "- **測試指令**: \`npm test\`"
            echo "- **構建指令**: \`npm run build\`"
            echo "- **代碼檢查**: \`npm run lint\`"
            echo "- **類型檢查**: \`npm run type-check\`"
            ;;
        "python")
            echo "- **開發指令**: \`python manage.py runserver\` 或 \`flask run\`"
            echo "- **測試指令**: \`pytest\` 或 \`python -m unittest\`"
            echo "- **依賴安裝**: \`pip install -r requirements.txt\`"
            echo "- **代碼檢查**: \`flake8\` 或 \`pylint\`"
            ;;
        "java")
            echo "- **構建指令**: \`mvn compile\`"
            echo "- **測試指令**: \`mvn test\`"
            echo "- **運行指令**: \`mvn spring-boot:run\`"
            echo "- **打包指令**: \`mvn package\`"
            ;;
        "go")
            echo "- **運行指令**: \`go run main.go\`"
            echo "- **測試指令**: \`go test ./...\`"
            echo "- **構建指令**: \`go build\`"
            echo "- **代碼檢查**: \`go vet\`"
            ;;
        "rust")
            echo "- **運行指令**: \`cargo run\`"
            echo "- **測試指令**: \`cargo test\`"
            echo "- **構建指令**: \`cargo build\`"
            echo "- **代碼檢查**: \`cargo clippy\`"
            ;;
        *)
            echo "- **開發指令**: [請填入開發指令]"
            echo "- **測試指令**: [請填入測試指令]"
            echo "- **構建指令**: [請填入構建指令]"
            ;;
    esac
}

# Generate project structure based on project type
generate_project_structure() {
    case $1 in
        "javascript")
            cat << 'EOF'
```
src/
├── components/         # 可重用組件
├── pages/             # 頁面組件  
├── hooks/             # 自定義 Hooks
├── utils/             # 工具函數
├── types/             # TypeScript 類型定義
├── api/               # API 相關
└── styles/            # 樣式文件
```
EOF
            ;;
        "python")
            cat << 'EOF'
```
src/
├── models/            # 數據模型
├── views/             # 視圖/控制器
├── services/          # 業務邏輯
├── utils/             # 工具函數
├── tests/             # 測試文件
└── config/            # 配置文件
```
EOF
            ;;
        *)
            cat << 'EOF'
```
src/
├── [請根據專案調整目錄結構]
```
EOF
            ;;
    esac
}

# Generate tech preferences based on project type
generate_tech_preferences() {
    case $1 in
        "javascript")
            cat << 'EOF'
### 常用技術偏好：
- **狀態管理**: [React Context, Zustand, Redux]
- **樣式方案**: [Tailwind CSS, CSS Modules, Styled Components]
- **HTTP 客戶端**: [fetch, axios]
- **測試框架**: [Jest, React Testing Library, Vitest]
- **包管理器**: [npm, yarn, pnpm]
EOF
            ;;
        "python")
            cat << 'EOF'
### 常用技術偏好：
- **Web 框架**: [Django, FastAPI, Flask]
- **ORM**: [Django ORM, SQLAlchemy, Peewee]
- **測試框架**: [pytest, unittest]
- **代碼格式**: [black, isort]
- **依賴管理**: [pip, poetry, pipenv]
EOF
            ;;
        *)
            cat << 'EOF'
### 常用技術偏好：
- **[技術類別]**: [請填入偏好的工具/框架]
EOF
            ;;
    esac
}

# Create .claudeignore file
create_claudeignore() {
    local project_dir=$1
    
    cat > "$project_dir/.claudeignore" << 'EOF'
# Claude Code 忽略文件
# 類似 .gitignore，但用於 Claude Code 互動時忽略某些文件

# 依賴目錄
node_modules/
venv/
env/
__pycache__/
.venv/
target/

# 構建輸出
dist/
build/
out/
*.min.js
*.min.css

# 日誌文件
*.log
logs/

# 臨時文件
.tmp/
temp/
.cache/

# IDE 文件
.vscode/
.idea/
*.swp
*.swo

# 系統文件
.DS_Store
Thumbs.db

# 大型數據文件
*.csv
*.json
*.xml
data/
datasets/

# 測試覆蓋報告
coverage/
.nyc_output/
.coverage

# 環境變數文件
.env
.env.local
.env.production
EOF

    print_success "Created .claudeignore file"
}

# Update existing installation
update_installation() {
    print_info "Updating Claude Code guide..."
    setup_global_config "--force"
    
    if check_project_directory; then
        local choice
        echo
        print_warning "偵測到當前目錄是一個專案，是否要更新專案中的指南文件？"
        read -p "更新當前專案？ (y/N): " choice
        
        if [[ $choice =~ ^[Yy]$ ]]; then
            install_to_project
        fi
    fi
}

# Show usage instructions
show_usage() {
    echo
    print_info "Claude Code 優化指南使用方法："
    echo
    echo "🚀 在任何專案中安裝："
    echo "   cd your-project && curl -sSL [install-url] | bash"
    echo
    echo "🔄 更新已安裝的指南："
    echo "   curl -sSL [install-url] | bash -s -- --update"
    echo
    echo "📋 全域使用 (一次設定，所有專案可用)："
    echo "   每次與 Claude Code 互動時加入："
    echo "   參考我的全域 Claude Code 指南，位於 ~/.claude-code-guide/"
    echo
    echo "📁 專案特定使用："
    echo "   參考專案中的 ClaudeCodeOptimizationGuide.md 和 CLAUDE.md"
    echo
}

# Main function
main() {
    print_header
    
    # Check parameters
    if [[ "$1" == "--update" ]]; then
        update_installation
        show_usage
        exit 0
    fi
    
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_usage
        exit 0
    fi
    
    # Setup global configuration
    setup_global_config
    
    # If in project directory, ask whether to install to project
    if check_project_directory; then
        echo
        print_info "偵測到當前目錄是一個專案目錄"
        local choice
        read -p "是否要安裝到當前專案？ (Y/n): " choice
        
        if [[ ! $choice =~ ^[Nn]$ ]]; then
            install_to_project
        fi
    else
        print_info "當前目錄非專案目錄，僅設定全域配置"
        echo
        print_info "要在專案中使用，請切換到專案目錄後重新執行安裝"
    fi
    
    echo
    print_success "安裝完成！"
    echo
    show_usage
    
    print_info "重新載入 shell 或執行: source ~/.bashrc (或 ~/.zshrc)"
}

# Execute main function
main "$@"