#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== OpenCode Dotfiles Setup ==="
echo ""

# 1. OpenCode 설정 디렉토리 생성
mkdir -p "$HOME/.config/opencode"
mkdir -p "$HOME/.local/share/opencode"

# 2. 기존 파일 백업 후 symlink
for file in opencode.json oh-my-opencode.json; do
    target="$HOME/.config/opencode/$file"
    source="$DOTFILES_DIR/opencode/$file"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        backup="${target}.bak.$(date +%Y%m%d-%H%M%S)"
        echo "[backup] $target -> $backup"
        mv "$target" "$backup"
    elif [ -L "$target" ]; then
        rm "$target"
    fi

    ln -s "$source" "$target"
    echo "[symlink] $target -> $source"
done

# 3. CLAUDE.md symlink
claude_target="$HOME/CLAUDE.md"
claude_source="$DOTFILES_DIR/CLAUDE.md"

if [ -e "$claude_target" ] && [ ! -L "$claude_target" ]; then
    backup="${claude_target}.bak.$(date +%Y%m%d-%H%M%S)"
    echo "[backup] $claude_target -> $backup"
    mv "$claude_target" "$backup"
elif [ -L "$claude_target" ]; then
    rm "$claude_target"
fi

ln -s "$claude_source" "$claude_target"
echo "[symlink] $claude_target -> $claude_source"

# 4. API 키 복호화
enc_file="$DOTFILES_DIR/opencode/auth.json.enc"
auth_target="$HOME/.local/share/opencode/auth.json"

if [ -f "$enc_file" ]; then
    if [ -e "$auth_target" ]; then
        backup="${auth_target}.bak.$(date +%Y%m%d-%H%M%S)"
        echo "[backup] $auth_target -> $backup"
        mv "$auth_target" "$backup"
    fi

    echo ""
    echo "API 키 복호화 중..."
    openssl enc -aes-256-cbc -d -salt -pbkdf2 -in "$enc_file" -out "$auth_target" -pass pass:"$1"

    if [ $? -eq 0 ]; then
        chmod 600 "$auth_target"
        echo "[decrypt] auth.json 복호화 완료"
    else
        echo "[error] 비밀번호가 틀렸습니다."
        exit 1
    fi
else
    echo "[skip] auth.json.enc 없음 — /connect 로 수동 연결 필요"
fi

# 5. opencode 설치 (없으면 자동 설치)
if ! command -v opencode &>/dev/null; then
    echo ""
    echo "opencode 미설치 — 자동 설치 중..."
    curl -fsSL https://opencode.ai/install | bash
    echo "[install] opencode 설치 완료"
else
    echo "[skip] opencode 이미 설치됨"
fi
# 6. 셸 환경 반영 안내
echo ""
echo "=== Setup Complete ==="
echo ""
echo "바로 사용하려면:"
echo "  source ~/.zshrc && opencode"
echo ""
