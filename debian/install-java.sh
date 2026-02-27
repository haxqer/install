#!/bin/bash
# ============================================================================
# install-java.sh - 安装 Java JDK + Maven
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在安装 Java JDK + Maven..."
apt update -y && \
    apt install -y \
        default-jdk \
        openjfx \
        maven

log_info "✅ Java 安装完成"
java -version 2>&1 | head -1
mvn -version 2>&1 | head -1
