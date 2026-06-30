#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
setup_file="$script_dir/setup.sh"
block_start="# >>> LinuxSetup setup >>>"
block_end="# <<< LinuxSetup setup <<<"

print_ok() {
    printf '\033[32m[OK]\033[0m %s\n' "$1"
}

print_warn() {
    printf '\033[33m[WARN]\033[0m %s\n' "$1"
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local answer suffix

    if [[ "$default" == "y" ]]; then
        suffix="[Y/n]"
    else
        suffix="[y/N]"
    fi

    while true; do
        read -r -p "$prompt $suffix " answer || answer=""
        answer="${answer:-$default}"
        case "$answer" in
            y|Y|yes|YES|Yes) return 0 ;;
            n|N|no|NO|No) return 1 ;;
            *) echo "请输入 y 或 n。" >&2 ;;
        esac
    done
}

prompt_value() {
    local prompt="$1"
    local default="${2:-}"
    local value

    if [[ -n "$default" ]]; then
        read -r -p "$prompt [$default]: " value || value=""
        printf '%s' "${value:-$default}"
    else
        read -r -p "$prompt: " value || value=""
        printf '%s' "$value"
    fi
}

prompt_required() {
    local prompt="$1"
    local value

    while true; do
        value="$(prompt_value "$prompt")"
        if [[ -n "$value" ]]; then
            printf '%s' "$value"
            return 0
        fi
        echo "这个值不能为空。" >&2
    done
}

default_rc_file() {
    local shell_name
    shell_name="$(basename "${SHELL:-bash}")"

    case "$shell_name" in
        zsh) printf '%s\n' "$HOME/.zshrc" ;;
        bash) printf '%s\n' "$HOME/.bashrc" ;;
        *) printf '%s\n' "$HOME/.bashrc" ;;
    esac
}

backup_file() {
    local file="$1"
    local backup="$file.bak.$(date +%Y%m%d%H%M%S)"

    cp "$file" "$backup"
    print_ok "已备份 $file -> $backup"
}

make_executable_if_present() {
    local path

    for path in \
        "$script_dir/setup.sh" \
        "$script_dir/firstime.sh" \
        "$script_dir/app/lazygit" \
        "$script_dir/app/yazi/yazi" \
        "$script_dir/app/yazi/ya"
    do
        if [[ -f "$path" ]]; then
            chmod +x "$path"
        fi
    done
}

write_shell_block() {
    local rc_file="$1"
    local enable_yazi="$2"
    local enable_lg="$3"
    local tmp_file

    mkdir -p "$(dirname "$rc_file")"
    if [[ -e "$rc_file" ]]; then
        backup_file "$rc_file"
    else
        touch "$rc_file"
    fi

    tmp_file="$(mktemp)"
    awk -v start="$block_start" -v end="$block_end" '
        $0 == start { skip = 1; next }
        $0 == end { skip = 0; next }
        !skip { print }
    ' "$rc_file" > "$tmp_file"

    {
        printf '\n%s\n' "$block_start"
        printf 'export LINUXSETUP_ENABLE_YAZI=%s\n' "$enable_yazi"
        printf 'export LINUXSETUP_ENABLE_LG=%s\n' "$enable_lg"
        printf 'source %q\n' "$setup_file"
        printf '%s\n' "$block_end"
    } >> "$tmp_file"

    mv "$tmp_file" "$rc_file"
    print_ok "已更新 shell 配置：$rc_file"
}

remove_shell_block() {
    local rc_file="$1"
    local tmp_file

    if [[ ! -e "$rc_file" ]]; then
        print_warn "配置文件不存在，跳过：$rc_file"
        return 0
    fi

    backup_file "$rc_file"
    tmp_file="$(mktemp)"
    awk -v start="$block_start" -v end="$block_end" '
        $0 == start { skip = 1; next }
        $0 == end { skip = 0; next }
        !skip { print }
    ' "$rc_file" > "$tmp_file"

    mv "$tmp_file" "$rc_file"
    print_ok "已移除 shell 配置中的 LinuxSetup 配置块：$rc_file"
}

configure_shortcuts() {
    local enable_yazi=0
    local enable_lg=0
    local rc_file

    if ask_yes_no "是否添加 yazi 快捷键 y？" "y"; then
        enable_yazi=1
    fi

    if ask_yes_no "是否添加 lazygit 快捷键 lg？" "y"; then
        enable_lg=1
    fi

    if [[ "$enable_yazi" == "0" && "$enable_lg" == "0" ]]; then
        if ask_yes_no "是否移除已有 LinuxSetup shell 配置块？" "n"; then
            rc_file="$(prompt_value "从哪个 shell 配置文件移除" "$(default_rc_file)")"
            remove_shell_block "$rc_file"
        else
            print_warn "未添加 yazi/lg 快捷键，shell 配置文件保持不变。"
        fi
        return 0
    fi

    rc_file="$(prompt_value "写入哪个 shell 配置文件" "$(default_rc_file)")"
    write_shell_block "$rc_file" "$enable_yazi" "$enable_lg"
}

configure_git_identity() {
    local default_name default_email name email

    if ! command -v git >/dev/null 2>&1; then
        print_warn "未找到 git，跳过 git 全局用户名配置。"
        return 0
    fi

    default_name="$(git config --global user.name 2>/dev/null || true)"
    default_email="$(git config --global user.email 2>/dev/null || true)"
    default_name="${default_name:-haoran}"
    default_email="${default_email:-liaohr9@mail2.sysu.edu.cn}"

    name="$(prompt_value "请输入 git 全局用户名" "$default_name")"
    email="$(prompt_value "请输入 git 全局邮箱" "$default_email")"

    if [[ -n "$name" ]]; then
        git config --global user.name "$name"
    fi

    if [[ -n "$email" ]]; then
        git config --global user.email "$email"
    fi

    print_ok "已更新 git 全局用户名和邮箱。"
}

select_pip_mode() {
    local mode

    while true; do
        echo "请选择 pip 配置方式：" >&2
        echo "  1) 只配置镜像 index-url" >&2
        echo "  2) 只配置 HTTP/HTTPS proxy" >&2
        echo "  3) 同时配置镜像和 proxy" >&2
        read -r -p "输入 1/2/3 [1]: " mode || mode=""
        mode="${mode:-1}"
        case "$mode" in
            1|2|3) printf '%s' "$mode"; return 0 ;;
            *) echo "请输入 1、2 或 3。" >&2 ;;
        esac
    done
}

configure_pip() {
    local pip_conf="$HOME/.pip/pip.conf"
    local mode index_url trusted_host proxy_url

    mode="$(select_pip_mode)"
    mkdir -p "$HOME/.pip"
    if [[ -e "$pip_conf" ]]; then
        backup_file "$pip_conf"
    fi

    index_url=""
    trusted_host=""
    proxy_url=""

    if [[ "$mode" == "1" || "$mode" == "3" ]]; then
        index_url="$(prompt_value "pip index-url" "https://pypi.mirrors.ustc.edu.cn/simple/")"
        trusted_host="$(prompt_value "pip trusted-host" "pypi.mirrors.ustc.edu.cn")"
    fi

    if [[ "$mode" == "2" || "$mode" == "3" ]]; then
        proxy_url="$(prompt_required "pip proxy，例如 http://127.0.0.1:7890")"
    fi

    {
        echo "[global]"
        if [[ -n "$index_url" ]]; then
            printf 'index-url = %s\n' "$index_url"
        fi
        if [[ -n "$trusted_host" ]]; then
            printf 'trusted-host = %s\n' "$trusted_host"
        fi
        if [[ -n "$proxy_url" ]]; then
            printf 'proxy = %s\n' "$proxy_url"
        fi
    } > "$pip_conf"

    print_ok "已写入 pip 配置：$pip_conf"
}

main() {
    echo "LinuxSetup first-time setup"
    echo "安装目录：$script_dir"
    echo

    make_executable_if_present

    configure_shortcuts

    if ask_yes_no "是否设置 git 全局用户名和邮箱？" "y"; then
        configure_git_identity
    fi

    if ask_yes_no "是否配置 pip 镜像或代理？" "y"; then
        configure_pip
    fi

    echo
    print_ok "完成。重新打开 shell，或执行：source $setup_file"
}

main "$@"
