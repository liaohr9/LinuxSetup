# 递归chmod 777
chmod -R 777 /mnt/afs/liaohaoran/LinuxSetup

# 设置git全局用户名和邮箱
git config --global user.name "haoran"
git config --global user.email "liaohr9@mail2.sysu.edu.cn"

# 配置pip换源
mkdir -p "$HOME/.pip"
cat > "$HOME/.pip/pip.conf" <<'EOF'
[global]
index-url=https://pypi.mirrors.ustc.edu.cn/simple/
[install]
trusted-host=https://pypi.mirrors.ustc.edu.cn
EOF