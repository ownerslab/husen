### ClipPad 付箋メモアプリ 導入・運用メモ

このファイルは、これまでのやり取りと「再起動後に何をすればよいか」をまとめたものです。  
**個人用の仮ペースト付箋メモアプリ ClipPad** を GitHub Actions でビルドし、Mac で運用することを想定しています。

---

## 1. アプリの概要

- **目的**:  
  - Web やドキュメントからコピーしたテキストを、一時的に「仮置き」しておく付箋メモアプリ  
  - 「コピー → 仮保存 → すぐ貼り付け」を最前面でサクサク行いたい
- **特徴**:
  - 常に最前面に表示（他のウィンドウの上に張り付き）
  - 複数モニター対応（好きなモニター/位置に配置）
  - コピー履歴を自動で貯める
  - クリックでクリップボードに戻して、すぐ貼り付け
  - 履歴の並べ替え（ドラッグ）
  - すべての仮置きデータを **一括削除ボタン** で消せる

---

## 2. 開発〜ビルドの流れ（GitHub Actions）

### 2.1 ローカルの構成

- プロジェクトルート: `/Users/shoheiyamada/Desktop/husen`
- 主なファイル:
  - `Husen/` … macOS アプリ本体（SwiftUI + AppKit）
  - `Husen.xcodeproj/` … Xcode プロジェクト
  - `docs/requirements.md` … 要件定義書
  - `.github/workflows/build-mac.yml` … GitHub Actions でのビルド定義
  - `README.md` … ビルドと利用手順の説明

### 2.2 Git / GitHub セットアップ

1. プロジェクトフォルダで Git 初期化・コミット（済み）  
   ```bash
   cd /Users/shoheiyamada/Desktop/husen
   git init
   git add .
   git commit -m "Initial commit: Husen 付箋メモアプリ（常時最前面・仮ペースト用）"
   ```

2. GitHub にリポジトリ `ownerslab/husen` を作成し、リモート登録・プッシュ  
   ```bash
   git remote add origin https://github.com/ownerslab/husen.git
   git push -u origin main
   ```

3. プッシュすると、`.github/workflows/build-mac.yml` によって  
   **"Build ClipPad for macOS"** ワークフローが自動で走る。

### 2.3 GitHub Actions 側の挙動

- `runs-on: macos-14` の Runner で `xcodebuild` 実行
- コードサインは **`CODE_SIGNING_ALLOWED=NO`** にして署名なしビルド
- 成功時:
  - `build/DerivedData/.../ClipPad.app` を `ditto` で ZIP 化
  - **Artifacts → ClipPad-macOS** として `ClipPad-macOS.zip` をアップロード
- 失敗時:
  - `ClipPad-build-logs` に `xcodebuild.log` と `result.xcresult` を保存  
    → エラー解析用

---

## 3. ClipPad.app の取得と初回起動

### 3.1 Artifact からの取得

1. GitHub の `ownerslab/husen` リポジトリ → **Actions** タブ
2. 最新の成功ジョブ **"CI: distribute ClipPad.app as ditto zip"** を開く
3. **Artifacts → ClipPad-macOS** をクリックしてダウンロード
4. ダウンロードした ZIP 内の `ClipPad-macOS.zip` を解凍  
   → `ClipPad.app` が得られる

### 3.2 アプリケーションフォルダへ配置

1. 解凍した `ClipPad.app` を Finder で  
   **`アプリケーション` フォルダにドラッグ**して移動

### 3.3 初回起動（ターミナルを使わない方法）

- リポジトリ内に **`初回起動用.command`** があります。  
  **ClipPad.app をアプリケーションに入れたあと、このファイルをダブルクリック**すると、隔離解除と起動を一度に実行できます（初回だけ実行すればOK）。
- ターミナルを使う場合（上記が使えないとき）:
  ```bash
  xattr -dr com.apple.quarantine "/Applications/ClipPad.app"
  open "/Applications/ClipPad.app"
  ```

### 3.4 2回目以降の起動

- Finder → アプリケーション → `ClipPad` をダブルクリック  
  もしくは Spotlight（⌘Space）で「ClipPad」と入力 → Enter

### 3.5 他ユーザー（妻など）への配布

- 同じ手順でOK:
  1. GitHub Actions の Artifacts から `ClipPad-macOS.zip` をダウンロード
  2. 解凍して `ClipPad.app` を **アプリケーション** フォルダに配置
  3. 初回のみ: ターミナルで `xattr -dr com.apple.quarantine "/Applications/ClipPad.app"` を実行  
     または `初回起動用.command` をダブルクリック  
     または 右クリック →「開く」
  4. 2回目以降は通常どおりダブルクリックで起動

---

## 4. ClipPad アプリの仕様（重要なポイント）

### 4.0 負荷

- 常時起動でも軽量: 0.5秒ごとのクリップボードポーリングのみ。CPU・メモリ負荷はごく小さい。

### 4.1 常に最前面 & ×で完全終了

- `AppDelegate.swift`:
  - `window.level = .floating` で最前面
  - `NSApp.setActivationPolicy(.regular)` で Dock に表示
  - `applicationShouldTerminateAfterLastWindowClosed` で × で完全終了

### 4.2 仮置きデータの管理（ClipboardStore）

- Clipboard の変更を 0.5 秒ごとにポーリングして監視
- テキストを検出すると自動で `items` 配列に追加
- 最大 `maxItems = 50` 件まで保存
- UserDefaults (`clippad.clipboard.items`) に永続化
- クリック時に `copyToPasteboard(_:)` でテキストをクリップボードへ戻す
- 行のドラッグ＆ドロップで並び替え（DropDelegate）
- **一括削除**:
  - `clearAll()` で `items.removeAll()` → `save()`  

### 4.3 UI（ContentView）

- 上部バー（統合）:
  - 左: `ClipPad` ＋ `仮置き場`
  - 右: テーマ選択（標準・ダーク・コックピット）＋ 一括削除アイコン
- メイン:
  - List に履歴一覧（コピー検知で自動追加、ショートカットで追加も可）
    - 行をクリックすると → クリップボードに戻す
    - 行をドラッグして → 並び替え
    - 右クリック（または長押し）コンテキストメニュー:
      - 「クリップボードに戻す」
      - 「削除」

---

## 5. 再起動後にやること（運用手順）

### 5.1 起動方法（通常）

- 再起動後は **普通のアプリと同じ**:
  - Finder → アプリケーション → `ClipPad` をダブルクリック
  - または Spotlight（⌘Space）で `ClipPad` と入力 → Enter
  - Dock にピン留めしている場合は、Dock のアイコンをクリック

### 5.2 万が一「壊れている/開けない」と出た場合

署名なしアプリなので、稀に Gatekeeper の警告が出ることがあります。

1. まず隔離属性を削除:
   ```bash
   xattr -dr com.apple.quarantine "/Applications/ClipPad.app"
   ```
2. 再度起動:
   ```bash
   open "/Applications/ClipPad.app"
   ```

### 5.3 `_LSOpenURLsWithCompletionHandler error -600` が出る場合

- Launch Services 周りが壊れたり、アプリが中途半端に残っていると起きるエラー。
- 対処手順:

  1. プロセスを念のため落とす:
     ```bash
     pkill ClipPad 2>/dev/null || true
     ```
  2. **Mac を再起動**（ → 再起動…）
  3. 再起動後にもう一度:
     ```bash
     xattr -dr com.apple.quarantine "/Applications/ClipPad.app"
     open "/Applications/ClipPad.app"
     ```

---

## 6. 今後やりたい改善メモ

- アイコン:
  - 自作した PNG を `Assets.xcassets` に追加
  - `AppIcon` を設定して、Dock/Launchpad でも “それっぽい” 見た目に
- UI:
  - 一括削除に確認ダイアログ（「本当に全削除しますか？」）
  - ショートカットキーの追加（例: ⌘⌫ で全削除）
- 配布:
  - 署名 & Notarization をして Gatekeeper 警告なしで配布（Apple Developer Program 登録後）

---

## 7. PC 買い替え時の復元手順

### 7.1 結論

- GitHub の `ownerslab/husen` リポジトリと Actions が残っていれば、**新しい Mac でも同じ ClipPad を再度使える**。
- 基本の流れは  
  **「GitHub から Artifact をダウンロード → ClipPad.app を解凍 → /Applications に入れる」** だけ。

### 7.2 新しい Mac での最小手順（Xcode 不要）

1. ブラウザで `ownerslab/husen` を開く。
2. **Actions タブ** → 最新の成功ジョブ `CI: distribute ClipPad.app as ditto zip` を開く。
3. 右側（または下部）の **Artifacts → ClipPad-macOS** をダウンロード。
4. ダウンロードした ZIP (`ClipPad-macOS.zip`) を解凍。  
   - 場合によっては中にさらに `ClipPad-macOS.zip` が入っているので、それももう一度解凍する。  
   - 最終的に **`ClipPad.app`** が出てくる。
5. `ClipPad.app` を Finder で **`アプリケーション` フォルダにドラッグ**。
6. ターミナルで初回の隔離解除と起動:
   ```bash
   xattr -dr com.apple.quarantine "/Applications/ClipPad.app"
   open "/Applications/ClipPad.app"
   ```
7. 以後は:
   - Finder → アプリケーション → `ClipPad` をダブルクリック
   - もしくは Spotlight（⌘Space）で `ClipPad` と入力 → Enter
   - Dock にピン留めしておけば Dock からワンクリック起動。

### 7.3 ソースコードごと持っていきたい場合（開発も続けるとき）

1. 新しい Mac でターミナルを開き、任意のフォルダ（例: デスクトップ）へ移動:
   ```bash
   cd ~/Desktop
   git clone https://github.com/ownerslab/husen.git
   ```
2. これで `~/Desktop/husen` に現在のプロジェクト一式（`Husen運用メモ.md` も含む）が取れる。
3. Xcode をインストール済みなら、`Husen.xcodeproj` を開いてそのまま開発を継続できる。  
   （使うだけなら、Actions → Artifact → ClipPad.app の方式だけで十分。）


