# ClipPad（仮置き場）

Mac 用の「常に最前面」付箋メモアプリ。WEB や他アプリでコピーしたテキストを仮保存し、すぐ貼り付けできる仮置き場として使います。

- [要件定義書](docs/requirements.md)
- [システム概要](docs/概要.md)
- [操作説明（ユーザー向け）](docs/操作説明.md)

## 必要な環境

- macOS 13.0 以上
- Xcode 14 以上（ビルド時）

## ビルド・実行

### Xcode で開くとは

1. **Finder** でこのフォルダ（`clippad`）を開く
2. **`ClipPad.xcodeproj`**（または `ClipPad` スキーム）をダブルクリックする  
   - 青いアイコンの「プロジェクト」ファイル（フォルダのように見えますが 1 つのファイルです）
   - これで **Xcode が起動し、プロジェクトが開く**想定です
3. Xcode が開いたら、メニュー **Product → Run**（またはキーボード **⌘R**）でビルド＆実行

**ダブルクリックしても「光るだけ」で Xcode が起動しない場合**

- **Xcode を先に起動**してから、メニュー **File → Open...** で `ClipPad.xcodeproj` を選んで開く
- または Xcode を起動し、出てきた「Open a project or file」で `clippad` フォルダ内の `ClipPad.xcodeproj` を指定する
- Xcode が入っていない場合は、App Store から「Xcode」をインストールする（無料・容量大）

### 手順まとめ

1. リポジトリをクローンまたはダウンロードする
2. `ClipPad.xcodeproj` をダブルクリック（または Xcode の File → Open で開く）
3. **Product → Run**（⌘R）でビルド＆実行

またはターミナルで（Xcode がインストールされている場合）:

```bash
cd /path/to/clippad
xcodebuild -scheme ClipPad -configuration Release -destination 'platform=macOS' build
# ビルド後は Xcode の DerivedData に .app ができます。Xcode で Run するのが簡単です
```

### PC に空き容量がない場合（Xcode を入れない方法）

**方法: GitHub でクラウドビルドし、できた .app だけダウンロードする**

あなたの Mac に Xcode は一切不要です。GitHub のサーバー（Mac）でビルドし、**完成した ClipPad.app をダウンロードして使う**だけです。

1. このフォルダ（`clippad`）を **GitHub のリポジトリ** にプッシュする（Git が未導入の場合は「Git で管理」してから GitHub に上げる）
2. プッシュすると **GitHub Actions** が自動でビルドを開始する
3. 完了後、リポジトリの **Actions** タブ → 直近の「Build ClipPad for macOS」→ **Artifacts** から **ClipPad-macOS** をダウンロード
4. ダウンロードした中にある **`ClipPad-macOS.zip`** を解凍すると **ClipPad.app** が出てくるので、アプリフォルダなどに置いてダブルクリックで起動

これなら **あなたの PC の空き容量はほとんど使わず**、同じ付箋メモアプリをそのまま使えます。ビルド用のワークフローは `.github/workflows/build-mac.yml` に用意済みです。

※ GitHub アカウントがない場合は、知人や別の Mac（Xcode 入り）で一度だけビルドしてもらい、ClipPad.app をもらって使う方法もあります。

**GitHub にプッシュする手順（初回のみ）**

1. [GitHub](https://github.com/new) で **New repository** を開く
2. **Repository name** に `clippad`（または任意の名前）を入力
3. **Public** を選び、**「Add a README file」にチェックを入れない**（既にローカルにあるため）
4. **Create repository** をクリック
5. 作成されたページに「…or push an existing repository from the command line」と出ているので、その中の **2 行**をターミナルで実行する（`YOUR_USERNAME` はあなたの GitHub ユーザー名に置き換え）:

```bash
cd /Users/shoheiyamada/Desktop/clippad
git remote add origin https://github.com/YOUR_USERNAME/clippad.git
git push -u origin main
```

6. プッシュ後、リポジトリの **Actions** タブでビルドが走り、数分で **ClipPad-macOS** の Artifact がダウンロードできるようになります。

## 主な機能

- **常に最前面**: ウィンドウが他のアプリより前面に表示される（F-01）
- **仮保存**: コピーすると自動で一覧に追加。手動で「追加」も可能（F-04, F-06）
- **クリックで貼り付け準備**: 一覧の項目をクリックするとクリップボードに戻るので、他アプリで ⌘V で貼り付け（F-05）
- **並べ替え**: 「編集」ボタンでリストを編集し、ドラッグで並び順を変更（F-07）
- **複数モニター**: ウィンドウを任意のモニターにドラッグして配置可能（F-08）
- **軽量**: Swift/AppKit のネイティブアプリで、起動・ドラッグが軽い（非機能要件）

## 使い方

1. アプリを起動すると小さいウィンドウが最前面に表示されます
2. 他アプリでテキストをコピー（⌘C）すると、自動で一覧に追加されます
3. 貼り付けたい項目をクリック → 他アプリで ⌘V で貼り付け
4. ウィンドウはタイトルバー（「仮置き場」のバー）をつかんでドラッグすると移動できます
5. 「編集」を押すと一覧の並べ替えができます

※  Dock には表示されない設定（アクセサリ）です。終了する場合はメニューバー「ClipPad → Quit」または ⌘Q で終了してください。
