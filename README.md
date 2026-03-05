# OpenCode Dotfiles

## 새 기기에서 셋업

```bash
git clone https://github.com/pascran/omo-Dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh <비밀번호>
```

비밀번호를 넣으면 API 키(5개) 자동 복호화. `/connect` 불필요.

## setup.sh 이 하는 일

- `~/.config/opencode/` 에 설정 파일 symlink 생성
- `~/CLAUDE.md` symlink 생성
- `auth.json.enc` 복호화 → API 키 자동 배치
- 기존 파일이 있으면 `.bak` 으로 백업

## 셋업 후 할 일

```bash
# opencode 설치 (안 되어있으면)
curl -fsSL https://opencode.ai/install | bash

# 바로 실행 — 플러그인 자동 설치됨
opencode
```

## API 키 갱신 시

```bash
cd ~/dotfiles
openssl enc -aes-256-cbc -salt -pbkdf2 -in ~/.local/share/opencode/auth.json -out opencode/auth.json.enc
git add -A && git commit -m "update auth" && git push
```

## 설정 변경 후 동기화

```bash
cd ~/dotfiles
git add -A && git commit -m "update config" && git push
```

다른 기기에서:

```bash
cd ~/dotfiles && git pull
```

symlink 이므로 pull 하면 바로 반영됨.
