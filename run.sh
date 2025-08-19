#!/usr/bin/env bash
set -e

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required but not installed." >&2
  exit 1
fi

if ! command -v docker compose >/dev/null 2>&1; then
  echo "Docker Compose is required but not installed." >&2
  exit 1
fi

mkdir -p in out

if [ ! -f .env ]; then
  echo "Missing .env file. Copy .env.example to .env and set OPENAI_API_KEY." >&2
  exit 1
fi

set -a
. ./.env
set +a

if [ $# -lt 1 ]; then
  echo "Usage: $0 <video-file> [--model <model>]" >&2
  exit 1
fi

VIDEO="$1"
shift

MODEL_ENV=""
if [ "$1" = "--model" ] && [ -n "$2" ]; then
  MODEL_ENV="-e MODEL=$2"
fi

if [ ! -f "in/$VIDEO" ]; then
  echo "Input file in/$VIDEO not found." >&2
  exit 1
fi

docker compose run --rm $MODEL_ENV autosub "/data/$VIDEO"
