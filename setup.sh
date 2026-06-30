#!/bin/bash

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    setup_source="${BASH_SOURCE[0]}"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
    eval 'setup_source="${(%):-%x}"'
else
    setup_source="$0"
fi

setup_source_dir="$(cd "$(dirname "$setup_source")" && pwd)"
if [[ -d "$setup_source_dir/app" ]]; then
    linux_setup_dir="$setup_source_dir"
elif [[ -d "$setup_source_dir/LinuxSetup/app" ]]; then
    linux_setup_dir="$setup_source_dir/LinuxSetup"
else
    linux_setup_dir="$setup_source_dir"
fi

base_dir="$(dirname "$linux_setup_dir")"
if [[ "$(basename "$base_dir")" == "code" ]]; then
    base_dir="$(dirname "$base_dir")"
fi

# This file can be sourced from any LinuxSetup location.

# echo -e "\033[32m[√] 加载 LinuxSetup/setup.sh 脚本\033[0m"

# ======================== conda =========================

export PATH=~/anaconda3/bin:$PATH

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!

# <<< conda initialize <<<

# RoboTwin

# ======================== yazi =========================
if [[ "${LINUXSETUP_ENABLE_YAZI:-1}" == "1" ]]; then
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	"$linux_setup_dir/app/yazi/yazi" "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
fi

# ================= tmux =================
# 通用 tmux 函数，接收路径参数
function tmux_base() {
    local pane_count="$1"
    local target_path="${2:-$(pwd)}"  # 默认为当前目录
    
    if [[ "$pane_count" == "1" ]]; then
        tmux new-session \; \
            send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter
    elif [[ "$pane_count" == "2" ]]; then
        tmux new-session \; \
            split-window -h \; \
            select-pane -t 0 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 1 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter
    elif [[ "$pane_count" == "4" ]]; then
        tmux new-session \; \
            split-window -h \; \
            split-window -v \; \
            select-pane -t 0 \; \
            split-window -v \; \
            select-pane -t 0 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 1 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 2 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 3 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter
    elif [[ "$pane_count" == "8" ]]; then
        tmux new-session \; \
            split-window -h \; \
            split-window -v \; \
            select-pane -t 0 \; \
            split-window -v \; \
            select-pane -t 0 \; \
            split-window -v \; \
            select-pane -t 2 \; \
            split-window -v \; \
            select-pane -t 4 \; \
            split-window -v \; \
            select-pane -t 6 \; \
            split-window -v \; \
            select-pane -t 0 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 1 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 2 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 3 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 4 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 5 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 6 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 7 \; send-keys "source \"$linux_setup_dir/setup.sh\"" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter
    else
        echo "错误：仅支持 1、2、4 或 8 个面板"
        return 1
    fi
}

# 通用 tmux 函数，使用参数控制面板数和路径
function tmuxx() {
    local pane_count="$1"
    local path_key="$2"
    
    # 如果没有提供路径参数，显示 tmux 会话列表并等待用户选择
    if [[ -z "$pane_count" ]]; then
        echo "当前 tmux 会话列表："
        tmux ls 2>/dev/null
        if [[ $? -ne 0 ]]; then
            echo "没有运行中的 tmux 会话"
            return 1
        fi
        echo -n "请输入要连接的会话编号: "
        read session_num
        tmux a -t "$session_num"
        return $?
    fi
    local target_path

    if [[ $pane_count == 'clean' ]]; then
        for session in $(tmux ls | cut -d: -f1); do
            tmux kill-session -t "$session"
        done
        echo -e "\033[32m[√] 已清除所有 tmux 会话\033[0m"
        return 0
    fi
    
    # 根据路径参数设置目标目录
    case "$path_key" in
        "dp3")
            target_path="$base_dir/code/LoopBreaker/policy/DP3"
            ;;
        "act")
            target_path="$base_dir/code/LoopBreaker/policy/ACT"
            ;;
        "pi0")
            target_path="$base_dir/code/LoopBreaker/policy/pi0"
            ;;
        "")
            target_path="$(pwd)"  # 默认为当前目录
            ;;
        *)
            target_path="$path_key"  # 直接使用提供的路径
            ;;
    esac
    
    tmux_base "$pane_count" "$target_path"
}

# check gpu and ssh info
function gpu() {
    gpustat2
    sshinfo
}

function g() {
    watch -n 1 gpustat
}

# ======================= lazygit ========================
if [[ "${LINUXSETUP_ENABLE_LG:-1}" == "1" ]]; then
function lg(){
 "$linux_setup_dir/app/lazygit" "$@"
}
fi

# ======================== hugging-face ========================
export HF_ENDPOINT=https://hf-mirror.com
