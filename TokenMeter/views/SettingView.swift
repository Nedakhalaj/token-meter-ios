//
//  SettingView.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-08-18.
//

import SwiftUI


enum ThemeMode: String, CaseIterable {
    case system
    case light 
    case dark
}

extension ThemeMode{
    var colorScheme : ColorScheme? {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return nil
            
        }
    }
}

struct SettingView: View {
    
    @AppStorage("theme") var theme: ThemeMode = .system
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $theme) {
                        ForEach(ThemeMode.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                                .tag($0)
                        }
                    }
                }
                Section(header: Text("About")){
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                    
                }
                
                Text("Your data stays on this device. Token Meter only reads your usage.")
                
            }
            .navigationTitle(Text("Settings"))
            .preferredColorScheme(theme.colorScheme)
        }
        
        
    }
}

#Preview {
    SettingView()
}
