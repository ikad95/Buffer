import SwiftUI
import Defaults
import Settings

struct StorageSettingsPane: View {
  @Observable
  class ViewModel {
    var saveFiles = false {
      didSet {
        Defaults.withoutPropagation {
          if saveFiles {
            Defaults[.enabledPasteboardTypes].formUnion(StorageType.files.types)
          } else {
            Defaults[.enabledPasteboardTypes].subtract(StorageType.files.types)
          }
        }
      }
    }

    var saveImages = false {
      didSet {
        Defaults.withoutPropagation {
          if saveImages {
            Defaults[.enabledPasteboardTypes].formUnion(StorageType.images.types)
          } else {
            Defaults[.enabledPasteboardTypes].subtract(StorageType.images.types)
          }
        }
      }
    }

    var saveText = false {
      didSet {
        Defaults.withoutPropagation {
          if saveText {
            Defaults[.enabledPasteboardTypes].formUnion(StorageType.text.types)
          } else {
            Defaults[.enabledPasteboardTypes].subtract(StorageType.text.types)
          }
        }
      }
    }

    private var observer: Defaults.Observation?

    init() {
      observer = Defaults.observe(.enabledPasteboardTypes) { change in
        self.saveFiles = change.newValue.isSuperset(of: StorageType.files.types)
        self.saveImages = change.newValue.isSuperset(of: StorageType.images.types)
        self.saveText = change.newValue.isSuperset(of: StorageType.text.types)
      }
    }

    deinit {
      observer?.invalidate()
    }
  }

  @Default(.size) private var size
  @Default(.unlimitedHistory) private var unlimitedHistory
  @Default(.enableLRU) private var enableLRU
  @Default(.lruKeepDays) private var lruKeepDays
  @Default(.sortBy) private var sortBy

  @State private var viewModel = ViewModel()
  @State private var storageSize = Storage.shared.size
  @State private var itemCount = 0

  private let sizeFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.minimum = 1
    formatter.maximum = 1_000_000
    return formatter
  }()

  private let daysFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.minimum = 1
    formatter.maximum = 365
    return formatter
  }()

  var body: some View {
    Settings.Container(contentWidth: 450) {
      Settings.Section(
        bottomDivider: true,
        label: { Text("Save", tableName: "StorageSettings") }
      ) {
        Toggle(
          isOn: $viewModel.saveFiles,
          label: { Text("Files", tableName: "StorageSettings") }
        )
        Toggle(
          isOn: $viewModel.saveImages,
          label: { Text("Images", tableName: "StorageSettings") }
        )
        Toggle(
          isOn: $viewModel.saveText,
          label: { Text("Text", tableName: "StorageSettings") }
        )
        Text("SaveDescription", tableName: "StorageSettings")
          .controlSize(.small)
          .foregroundStyle(.gray)
      }

      Settings.Section(label: { Text("Size", tableName: "StorageSettings") }) {
        Toggle(
          isOn: $unlimitedHistory,
          label: { Text("Unlimited history", tableName: "StorageSettings") }
        )
        .help("Store unlimited clipboard items (uses more disk space)")

        if !unlimitedHistory {
          HStack {
            TextField("", value: $size, formatter: sizeFormatter)
              .frame(width: 80)
              .help(Text("SizeTooltip", tableName: "StorageSettings"))
            Stepper("", value: $size, in: 1...1_000_000)
              .labelsHidden()
            Text("items")
              .controlSize(.small)
              .foregroundStyle(.gray)
          }
        }

        HStack {
          Text("\(itemCount) items")
            .controlSize(.small)
            .foregroundStyle(.secondary)
          Text("(\(storageSize))")
            .controlSize(.small)
            .foregroundStyle(.gray)
        }
        .onAppear {
          storageSize = Storage.shared.size
          Task { @MainActor in
            itemCount = History.shared.all.count
          }
        }
      }

      Settings.Section(
        bottomDivider: true,
        label: { Text("Auto-Cleanup", tableName: "StorageSettings") }
      ) {
        Toggle(
          isOn: $enableLRU,
          label: { Text("Remove old items automatically", tableName: "StorageSettings") }
        )
        .help("Automatically remove items older than the specified days")

        if enableLRU {
          HStack {
            Text("Keep items for", tableName: "StorageSettings")
            TextField("", value: $lruKeepDays, formatter: daysFormatter)
              .frame(width: 50)
            Stepper("", value: $lruKeepDays, in: 1...365)
              .labelsHidden()
            Text("days", tableName: "StorageSettings")
          }
        }
      }

      Settings.Section(label: { Text("SortBy", tableName: "StorageSettings") }) {
        Picker("", selection: $sortBy) {
          ForEach(Sorter.By.allCases) { mode in
            Text(mode.description)
          }
        }
        .labelsHidden()
        .frame(width: 160, alignment: .leading)
        .help(Text("SortByTooltip", tableName: "StorageSettings"))
      }
    }
  }
}

#Preview {
  StorageSettingsPane()
    .environment(\.locale, .init(identifier: "en"))
}
