import SwiftUI
import AppKit

/// メインの一覧UI（要件 F-04, F-05, F-07 / 案A: 一覧形式）
struct ContentView: View {
    @StateObject private var store = ClipboardStore.shared
    @State private var selectedId: ClipItem.ID?
    @State private var manualInput = ""
    @Environment(\.editMode) private var editMode

    var body: some View {
        VStack(spacing: 0) {
            // タイトルバー代わり・ドラッグ用（F-03: つまんで動かす）
            HStack {
                Text("仮置き場")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(editMode?.wrappedValue.isEditing == true ? "完了" : "編集") {
                    withAnimation(.snappy) {
                        if editMode?.wrappedValue.isEditing == true {
                            editMode?.wrappedValue = .inactive
                        } else {
                            editMode?.wrappedValue = .active
                        }
                    }
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // 手動追加（任意）
            HStack {
                TextField("貼り付けて追加", text: $manualInput, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(2...4)
                Button("追加") {
                    store.addItem(text: manualInput)
                    manualInput = ""
                }
                .buttonStyle(.borderedProminent)
                .disabled(manualInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(8)

            Divider()

            // 一覧（クリックでクリップボードに戻す / ドラッグで並べ替え）
            List(selection: $selectedId) {
                ForEach(store.items) { item in
                    ClipRowView(item: item, isSelected: selectedId == item.id)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedId = item.id
                            store.copyToPasteboard(item)
                        }
                        .contextMenu {
                            Button("クリップボードに戻す") {
                                store.copyToPasteboard(item)
                            }
                            Button("削除", role: .destructive) {
                                store.deleteItem(item)
                            }
                        }
                }
                .onMove(perform: store.move)
            }
            .listStyle(.plain)
        }
        .frame(minWidth: 280, minHeight: 200)
    }
}

struct ClipRowView: View {
    let item: ClipItem
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.preview)
                .font(.system(.body, design: .default))
                .lineLimit(2)
                .truncationMode(.tail)
                .foregroundColor(isSelected ? .accentColor : .primary)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
        .frame(width: 320, height: 400)
}
