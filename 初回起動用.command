#!/bin/bash
# Husen を一度だけ隔離解除して起動します。Husen.app をアプリケーションに入れたあと、このファイルをダブルクリックしてください。
xattr -dr com.apple.quarantine "/Applications/Husen.app" 2>/dev/null || true
open "/Applications/Husen.app"
