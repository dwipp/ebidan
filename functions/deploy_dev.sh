#!/bin/bash
set -e

firebase use ebidan-dev

if [ -z "$1" ]; then
  echo "⚠️  Tidak ada nama function → deploy SEMUA Cloud Functions"
  firebase deploy --only functions
else
  echo "🚀 Deploy function: $1"
  firebase deploy --only functions:$1
fi
