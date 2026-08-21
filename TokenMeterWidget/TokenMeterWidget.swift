//
//  TokenMeterWidget.swift
//  TokenMeterWidget
//
//  Created by neda khalajnejad on 2026-08-19.
//

import WidgetKit
import SwiftUI

struct UsageTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), accounts: Account.sample)   // fake data for the skeleton
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), accounts: AccountFileStore.load())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), accounts: AccountFileStore.load())
        // ask iOS to re-read the file in ~30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}


struct SimpleEntry: TimelineEntry {
    let date: Date
    let accounts: [Account]
}

struct TokenMeterWidgetEntryView: View {
    var entry: UsageTimelineProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if entry.accounts.isEmpty {
                Text("No accounts yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entry.accounts) { account in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(account.nickname)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Spacer()
                            if let window = account.windows.first {
                                Text(window.fraction, format: .percent.precision(.fractionLength(0)))
                                    .font(.caption)
                                    .monospacedDigit()
                            }
                        }
                        if let window = account.windows.first {
                            ProgressView(value: window.fraction)
                                .tint(barColor(for: window.fraction))
                        }
                    }
                }
            }
        }
    }

    // The widget can't see Theme.swift, so it has its own copy of the color rule.
    private func barColor(for fraction: Double) -> Color {
        switch fraction {
        case ..<0.5: return .green
        case ..<0.8: return .orange
        default:     return .red
        }
    }
}

struct TokenMeterWidget: Widget {
    let kind: String = "TokenMeterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UsageTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                TokenMeterWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TokenMeterWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Token Meter")
        .description("Your AI usage at a glance.")
    }
}

#Preview(as: .systemSmall) {
    TokenMeterWidget()
} timeline: {
    SimpleEntry(date: .now, accounts: Account.sample)
}
