#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

DB_NAME="lecture_feedback_survey_db"

echo "==> D1データベースを作成しています..."
CREATE_OUTPUT="$(npx wrangler d1 create "$DB_NAME" 2>&1)" || {
  echo "$CREATE_OUTPUT"
  if echo "$CREATE_OUTPUT" | grep -qi "already exists"; then
    echo "==> 既存のデータベースを使用します。"
  else
    echo "エラー: D1データベースの作成に失敗しました。" >&2
    exit 1
  fi
}
echo "$CREATE_OUTPUT"

DATABASE_ID="$(echo "$CREATE_OUTPUT" | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | head -1)"

if [ -z "$DATABASE_ID" ]; then
  echo "==> database_id を自動取得できなかったため、既存のwrangler.tomlの値を確認してください。"
  DATABASE_ID="$(grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' wrangler.toml | head -1)"
fi

if [ -z "$DATABASE_ID" ]; then
  echo "エラー: database_id が特定できませんでした。wrangler.toml を手動で編集してください。" >&2
  exit 1
fi

echo "==> wrangler.toml に database_id ($DATABASE_ID) を設定します..."
sed -i.bak "s/REPLACE_WITH_D1_DATABASE_ID/$DATABASE_ID/" wrangler.toml
rm -f wrangler.toml.bak

echo "==> テーブルを作成します..."
npx wrangler d1 execute "$DB_NAME" --remote --file=schema.sql

echo "==> デプロイします..."
npx wrangler deploy

echo "==> 完了しました。上記の出力に表示された URL が公開URLです。"
