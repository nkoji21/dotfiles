---
name: pr-flow-ja
description: Full PR workflow (Japanese) - end-to-end automation from branch creation, commit, draft PR, AI review loop, to squash-merge.
user-invocable: true
allowed-tools: Bash, Skill, Agent
---

ステージ済みの変更からsquash-mergeされたPRまで、プルリクエストの全ワークフローを自動化します。

**現在のブランチ:** `!`git branch --show-current``

**作業ツリーの状態:**
```
!`git status --short`
```

## Phase 1: Worktree

`git-worktree` スキルを Skill ツールで実行する。

worktreeパス（例: `/tmp/feat-foo`）とブランチ名が返される。両方を保存する：
- `WORKTREE_PATH` — worktreeへの絶対パス
- `BRANCH_NAME` — worktree内に作成されたブランチ名

## Phase 2: コミット

コミット前の HEAD sha を記録する：
```
BEFORE_SHA=$(git -C $WORKTREE_PATH rev-parse HEAD)
```

`git-commit-ja` スキルを `--path $WORKTREE_PATH` 引数付きで Skill ツールで実行する。

スキル完了後、コミットが実行されたか確認する：
```
AFTER_SHA=$(git -C $WORKTREE_PATH rev-parse HEAD)
```

`BEFORE_SHA == AFTER_SHA` の場合、worktreeをクリーンアップして停止する：
```
git worktree remove --force $WORKTREE_PATH
```
コミットする変更がなかったこと、元のリポジトリの変更はそのまま残っていることをユーザーに伝える。

## Phase 3: PR作成

`git-pr-ja` スキルを `--path $WORKTREE_PATH` 引数付きで Skill ツールで実行する。

スキル完了後、PR URLを取得する：
```
cd $WORKTREE_PATH && gh pr view --json url --jq '.url'
```

`gh pr create` がPR既存エラーで失敗した場合は、同じコマンドで既存のPR URLを取得する。

このURLを保存する — 以降の `gh pr comment` と `gh pr merge` の呼び出しで使用する。

## Phase 4: レビューループ

このループは最大 **3回** まで実行できる。イテレーション数を0から追跡する。

### 4a. レビュアーサブエージェントの起動

Agent ツールで `pr-reviewer` サブエージェントを以下のプロンプト（実際のPR URLに置き換え）で起動する：

```
Review the PR at <PR_URL>. Run `gh pr diff <PR_URL>` to get the diff. Analyze it for bugs, logic errors, security issues, and style/convention violations. Return structured findings exactly as your instructions specify — the REVIEW_RESULT block only, no prose outside it.
```

### 4b. レビューコメントの検証と投稿

投稿前に、サブエージェントのレスポンスに `REVIEW_RESULT` ... `END_REVIEW_RESULT` ブロックが含まれているか確認する。ブロックが存在しないか不正な場合は、代わりに以下の警告を投稿してPhase 5に進む：
```
gh pr comment <PR_URL> --body "[Claude Codeによる自動レビュー] 警告：レビュアーが不正な出力を返しました。自動修正をスキップします。手動でレビューしてください。"
```

正常な場合は、結果を投稿する：
```
gh pr comment <PR_URL> --body "[Claude Codeによる自動レビュー]

<フォーマットされたレビュー結果>"
```

結果はmarkdownリスト形式で。各項目: 重要度ラベル（`must-fix` / `suggestion` / `nitpick`）、ファイル/箇所、説明。

### 4c. 結果の評価

- **問題なし**（`issues: []` を含む）または **`suggestion`/`nitpick` のみ**: Phase 5に進む。
- **`must-fix` が存在し、かつ iteration < 3**:
  - 指摘されたファイルを読んでから編集する。各 `must-fix` 問題を修正する。
  - git-commit 実行前の HEAD sha を記録する：
    ```
    FIX_BEFORE=$(git -C $WORKTREE_PATH rev-parse HEAD)
    ```
  - `git-commit-ja` スキルを `--path $WORKTREE_PATH` 引数付きで Skill ツールで実行して修正をコミットする。
  - コミットが実際に行われたか確認する：
    ```
    FIX_AFTER=$(git -C $WORKTREE_PATH rev-parse HEAD)
    ```
  - `FIX_BEFORE == FIX_AFTER`（コミットなし）の場合: 修正をコミットできなかった旨のコメントを投稿し、worktreeをクリーンアップ（`git worktree remove --force $WORKTREE_PATH`）してから停止する。ループしないこと。
  - イテレーション数をインクリメントして4aに戻る。
- **`must-fix` が存在し、かつ iteration == 3**:
  - コメントを投稿する：
    ```
    gh pr comment <PR_URL> --body "[Claude Codeによる自動レビュー] 自動修正の最大回数（3回）に達しました。残りのmust-fix問題は手動対応が必要です。"
    ```
  - worktreeをクリーンアップする：
    ```
    git worktree remove --force $WORKTREE_PATH
    ```
  - 停止する。マージには進まないこと。

## Phase 5: LGTM + マージ

LGTMコメントを投稿する：
```
gh pr comment <PR_URL> --body "[Claude CodeによるLGTM]

must-fix問題は見つかりませんでした。自動マージを開始します。"
```

ドラフトPRをマージするために、レビュー準備完了にマークする：
```
gh pr ready <PR_URL>
```

squashマージをトリガーする：
```
gh pr merge <PR_URL> --squash --auto
```

マージコマンドが失敗した場合は、エラー内容をユーザーに報告して停止する。自動リトライはしないこと。

マージ成功後、worktreeをクリーンアップする：
```
git worktree remove --force $WORKTREE_PATH
```

最終的なPR URLとマージ結果をユーザーに報告する。
