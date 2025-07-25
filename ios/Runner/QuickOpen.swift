import AppIntents
import intelligence

@available(iOS 16, *)
struct ChatAppIntent: AppIntent {
  static var title: LocalizedStringResource = "与小桐"
  static var openAppWhenRun: Bool = true
    
  @Parameter(title: "行为")
  var target: RepresentableEntity
  
  @MainActor
  func perform() async throws -> some IntentResult {
    IntelligencePlugin.notifier.push(target.id)
    return .result()
  }
  
  static var parameterSummary: some ParameterSummary {
    Summary("与小桐做什么")
  }
}


struct AppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: ChatAppIntent(),
      phrases: [
        "在\(.applicationName)里告诉小桐"
      ]
    )
  }
}
