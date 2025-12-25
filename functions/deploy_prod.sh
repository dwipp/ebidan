#!/bin/bash
set -e

firebase use ebidan-prod

if [ -z "$1" ]; then
  echo "⚠️  Tidak ada nama function → deploy SEMUA Cloud Functions (PROD)"
else
  echo "🚀 Deploy function (PROD): $1"
fi

read -p "Ketik YES untuk lanjut: " confirm
if [ "$confirm" != "YES" ]; then
  echo "❌ Deploy dibatalkan"
  exit 1
fi

if [ -z "$1" ]; then
  firebase deploy --only functions
else
  firebase deploy --only functions:$1
fi
