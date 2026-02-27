#!/bin/bash
# ============================================================================
# pull-k8s-images.sh - 从 haxqer 镜像拉取 k8s 组件并 tag 为 k8s.gcr.io
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

K8S_VERSION="v1.16.3"

# 镜像映射: haxqer源 -> k8s.gcr.io目标
declare -A IMAGES=(
    ["kube-apiserver:${K8S_VERSION}"]="k8s.gcr.io/kube-apiserver:${K8S_VERSION}"
    ["kube-controller-manager:${K8S_VERSION}"]="k8s.gcr.io/kube-controller-manager:${K8S_VERSION}"
    ["kube-scheduler:${K8S_VERSION}"]="k8s.gcr.io/kube-scheduler:${K8S_VERSION}"
    ["kube-proxy:${K8S_VERSION}"]="k8s.gcr.io/kube-proxy:${K8S_VERSION}"
    ["pause:3.1"]="k8s.gcr.io/pause:3.1"
    ["etcd:3.3.15-0"]="k8s.gcr.io/etcd:3.3.15-0"
    ["coredns:1.6.2"]="k8s.gcr.io/coredns:1.6.2"
)

log_info "拉取 k8s 镜像 (版本: ${K8S_VERSION})..."

for src in "${!IMAGES[@]}"; do
    local_image="haxqer/${src}"
    target_image="${IMAGES[$src]}"

    log_info "拉取 ${local_image}..."
    docker pull "${local_image}"

    log_info "标记 ${local_image} -> ${target_image}"
    docker tag "${local_image}" "${target_image}"
done

log_info "✅ k8s 镜像拉取完成"
