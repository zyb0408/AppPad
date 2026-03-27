import Foundation

@MainActor
final class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()

    private let fileManager = FileManager.default
    private let label = "\(Bundle.main.bundleIdentifier ?? "com.yingbin.AppPad").launch-at-login"

    private init() {}

    var isEnabled: Bool {
        fileManager.fileExists(atPath: plistURL.path)
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try installLaunchAgent()
            try loadLaunchAgent()
        } else {
            try unloadLaunchAgentIfNeeded()
            if fileManager.fileExists(atPath: plistURL.path) {
                try fileManager.removeItem(at: plistURL)
            }
        }
    }

    private var plistURL: URL {
        fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents", isDirectory: true)
            .appendingPathComponent("\(label).plist")
    }

    private func installLaunchAgent() throws {
        let launchAgentsURL = plistURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: launchAgentsURL, withIntermediateDirectories: true)

        let plist = try launchAgentPlist()
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: plistURL, options: .atomic)
    }

    private func launchAgentPlist() throws -> [String: Any] {
        guard let executableURL = Bundle.main.executableURL else {
            throw LaunchAtLoginError.missingExecutable
        }

        let bundleURL = Bundle.main.bundleURL
        let useOpenCommand = bundleURL.pathExtension == "app"
        let arguments: [String]

        if useOpenCommand {
            arguments = ["/usr/bin/open", bundleURL.path]
        } else {
            arguments = [executableURL.path]
        }

        return [
            "Label": label,
            "ProgramArguments": arguments,
            "RunAtLoad": true,
            "LimitLoadToSessionType": ["Aqua"],
            "ProcessType": "Interactive"
        ]
    }

    private func loadLaunchAgent() throws {
        let userID = getuid()
        let bootstrap = Process()
        bootstrap.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        bootstrap.arguments = ["bootstrap", "gui/\(userID)", plistURL.path]

        do {
            try run(bootstrap)
        } catch {
            try unloadLaunchAgentIfNeeded()

            let retry = Process()
            retry.executableURL = URL(fileURLWithPath: "/bin/launchctl")
            retry.arguments = ["bootstrap", "gui/\(userID)", plistURL.path]
            try run(retry)
        }
    }

    private func unloadLaunchAgentIfNeeded() throws {
        let userID = getuid()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["bootout", "gui/\(userID)", plistURL.path]

        do {
            try run(process)
        } catch {
            if fileManager.fileExists(atPath: plistURL.path) {
                throw error
            }
        }
    }

    private func run(_ process: Process) throws {
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let errorData = stderr.fileHandleForReading.readDataToEndOfFile()
            let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: errorData.isEmpty ? outputData : errorData, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            throw LaunchAtLoginError.commandFailed(message?.isEmpty == false ? message! : "launchctl exited with status \(process.terminationStatus)")
        }
    }
}

enum LaunchAtLoginError: LocalizedError {
    case missingExecutable
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingExecutable:
            return "未找到当前应用的可执行文件。"
        case .commandFailed(let message):
            return message
        }
    }
}
