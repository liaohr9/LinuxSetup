#!/bin/bash

base_dir="/home/scc/cuixj/workspace2"

# ======================== conda =========================

export PATH=~/anaconda3/bin:$PATH

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
function ci() {
    condaon
}
# <<< conda initialize <<<

# RoboTwin
function rt() {
    echo -e "\033[32m[√] conda 初始化中...\033[0m"
    ci 
    echo -e "\033[32m[√] conda 初始化成功\033[0m"
    echo -e "\033[32m[√] 激活 RoboTwin 环境...\033[0m"
    conda activate RoboTwin
    echo -e "\033[32m[√] RoboTwin 环境激活成功\033[0m"

    # 保证which python 指向RoboTwin环境的python,否则conda deactivate, 再次激活环境
    if [[ "$(which python)" != *"RoboTwin"* ]]; then
        echo -e "\033[33m[!] 检测到 Python 路径异常，正在尝试修复...\033[0m"
        conda deactivate
        conda activate RoboTwin
        if [[ "$(which python)" == *"RoboTwin"* ]]; then
            echo -e "\033[32m[√] Python 路径修复成功\033[0m"
        else
            echo -e "\033[31m[×] Python 路径修复失败，请手动检查\033[0m"
        fi
    fi
}

# ======================== yazi =========================
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	$base_dir/app/yazi/yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# ================= tmux =================
# 通用 tmux 函数，接收路径参数
function tmux_base() {
    local pane_count="$1"
    local target_path="${2:-$(pwd)}"  # 默认为当前目录
    
    if [[ "$pane_count" == "1" ]]; then
        tmux new-session \; \
            send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter
    elif [[ "$pane_count" == "2" ]]; then
        tmux new-session \; \
            split-window -h \; \
            select-pane -t 0 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 1 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter
    elif [[ "$pane_count" == "4" ]]; then
        tmux new-session \; \
            split-window -h \; \
            split-window -v \; \
            select-pane -t 0 \; \
            split-window -v \; \
            select-pane -t 0 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 1 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 2 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 3 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter
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
            select-pane -t 0 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 1 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 2 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 3 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 4 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 5 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 6 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter \; \
            select-pane -t 7 \; send-keys "source $base_dir/setup.sh" Enter \; send-keys "cd \"$target_path\"" Enter \; send-keys "rt" Enter
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
function lg(){
 $base_dir/app/lazygit
}

# ======================== hugging-face ========================
export HF_ENDPOINT=https://hf-mirror.com


# 从远程主机获取文件
function getfrom() {
    local sshname="$1"
    local remote_path="$2"
    local local_dest="${3:-/home/liaohaoran/receive_files/}"

    if [[ -z "$sshname" ]] || [[ -z "$remote_path" ]]; then
        echo "用法: getfrom <主机名> <远程路径> [本地目标路径]"
        return 1
    fi
    
    # 如果sshname为dex:
    if [[ "$sshname" == "dex" ]]; then
        rsync -avP --progress "$sshname:$remote_path" "$local_dest"
    elif [[ "$sshname" == "a" ]]; then
        rsync -avP --progress "$sshname:$remote_path" "$local_dest"
    elif [[ "$sshname" == "cluster" || "$sshname" == "230" ]]; then
        rsync -avP --progress "$sshname:$remote_path" "$local_dest"
    elif [[ "$sshname" == "ps" ]]; then
        rsync -avP --progress "$sshname:$remote_path" "$local_dest"
    elif [[ "$sshname" == "zc"* ]]; then
        rsync -avP --progress "$sshname:$remote_path" "$local_dest"
    else
        echo "错误: 未知的 SSH 目标 '$sshname'"
        return 1
    fi
}