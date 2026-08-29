#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if ! command -v docker >/dev/null 2>&1; then
    printf '%s\n' "错误：未找到 Docker，请先安装 Docker Desktop 或 Docker Engine。" >&2
    exit 1
fi

if docker compose version >/dev/null 2>&1; then
    COMPOSE=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE=(docker-compose)
else
    printf '%s\n' "错误：未找到 Docker Compose，请安装 Docker Compose。" >&2
    exit 1
fi

case "${1:-start}" in
    start)
        "${COMPOSE[@]}" up --build
        ;;
    stop)
        "${COMPOSE[@]}" down
        ;;
    restart)
        "${COMPOSE[@]}" down
        "${COMPOSE[@]}" up --build
        ;;
    logs)
        "${COMPOSE[@]}" logs -f
        ;;
    build)
        "${COMPOSE[@]}" build
        ;;
    *)
        printf '用法：%s [start|stop|restart|logs|build]\n' "$(basename "$0")" >&2
        exit 2
        ;;
esac
