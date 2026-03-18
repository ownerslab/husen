#!/bin/bash
# ClipPad を一度だけ隔離解除して起動します。ClipPad.app をアプリケーションに入れたあと、このファイルをダブルクリックしてください。
xattr -dr com.apple.quarantine "/Applications/ClipPad.app" 2>/dev/null || true
open "/Applications/ClipPad.app"
