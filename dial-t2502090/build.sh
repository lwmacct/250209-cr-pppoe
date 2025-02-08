#!/usr/bin/env bash
# shellcheck disable=SC2317
# document https://www.yuque.com/lwmacct/docker/buildx

# exit 0
__main() {
    # 准备工作
    _sh_path=$(realpath "$(ps -p $$ -o args= 2>/dev/null | awk '{print $2}')") # 当前脚本路径
    _pro_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-2)}')               # 当前项目名
    _dir_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-1)}')               # 当前目录名
    _image="${_pro_name}:$_dir_name"

    {
        #  生成Dockerfile
        cd "$(dirname "$_sh_path")" || exit 1
        cat <<"EOF" >Dockerfile
FROM ghcr.io/lwmacct/250209-cr-ubuntu:noble-t2502090

LABEL org.opencontainers.image.source=https://github.com/lwmacct/250209-cr-pppoe
LABEL org.opencontainers.image.description="My container image"
LABEL org.opencontainers.image.licenses=MIT

ARG DEBIAN_FRONTEND=noninteractive
RUN set -eux; echo "apt"; \
    apt-get update && apt-get install -y --no-install-recommends pppoe* miniupnpd miniupnpc isc-dhcp-server isc-dhcp-client arping ipcalc mtr iperf3 -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*;

EOF
        sed -i "s/SED_REPLACE/$_image/g" Dockerfile
    }

    # 打包进行
    {
        cd "$(dirname "$_sh_path")" || exit 1
        # 开始构建
        jq 'del(.credsStore)' ~/.docker/config.json | sponge ~/.docker/config.json 2>/dev/null

        _registry="ghcr.io/lwmacct" # 远程注册地址, 如果是 hub.docker.com 则为用户名
        _repository="$_registry/$_image"

        docker buildx use default
        docker buildx build --platform linux/amd64 -t "$_repository" --network host --progress plain --load . && {
            if false; then
                docker rm -f sss
                docker run -itd --name=sss \
                    --ipc=host \
                    --network=host \
                    --cgroupns=host \
                    --privileged=true \
                    --security-opt apparmor=unconfined \
                    "$_repository"
                docker exec -it sss bash
            fi
        }

        docker push "$_repository"
        echo "images: $_repository"

    }

}

__main

__help() {
    cat >/dev/null <<"EOF"
这里可以写一些备注

ghcr.io/lwmacct/250209-cr-pppoe:dial-t2502090

EOF
}
