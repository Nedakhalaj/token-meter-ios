//
//  CodexLoginScreen.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-09-28.
//

import SwiftUI

struct CodexLoginScreen: View {
    let onConnect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .loading
    @State private var attempt = 0
    private let auth = CodexAuthService()

    private enum Phase {
        case loading
        case waiting(CodexDeviceCode)
        case failed(String)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch phase {
                case .loading:
                    ProgressView("Getting a code…")
                case .waiting(let code):
                    waitingView(code)
                case .failed(let message):
                    ContentUnavailableView {
                        Label("Sign-in didn't finish", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try again") { attempt += 1 }
                            .buttonStyle(.glassProminent)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Sign in to Codex")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task(id: attempt) { await signIn() }
        }
    }

    private func waitingView(_ code: CodexDeviceCode) -> some View {
        VStack(spacing: 20) {
            Text("Open the link below on any device where you're signed in to ChatGPT, then enter this code.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text(code.userCode)
                .font(.system(.largeTitle, design: .monospaced).weight(.semibold))
                .textSelection(.enabled)

            Button("Copy code") { UIPasteboard.general.string = code.userCode }
                .buttonStyle(.glass)

            Link("auth.openai.com/codex/device", destination: CodexOAuth.verificationURL)
            Text("If ChatGPT asks, turn on device code sign-in in Settings → Security.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                ProgressView()
                Text("Waiting for approval…").foregroundStyle(.secondary)
            }
        }
    }

    private func signIn() async {
        phase = .loading
        do {
            let code = try await auth.requestCode()
            phase = .waiting(code)
            let credential = try await auth.waitForApproval(code)
            onConnect(credential.secret)
        } catch is CancellationError {
            // The screen was closed. Nothing to show.
        } catch CodexAuthError.expired {
            phase = .failed("The code expired. Try again to get a new one.")
        } catch CodexAuthError.declined {
            phase = .failed("The sign-in was declined on ChatGPT.")
        } catch {
            phase = .failed("Something went wrong talking to OpenAI. Try again.")
        }
    }
}

#Preview {
    CodexLoginScreen(onConnect: { _ in })
}
