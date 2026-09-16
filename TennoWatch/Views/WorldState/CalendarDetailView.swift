//
//  CalendarDetailView.swift
//  TennoWatch
//

import SwiftUI

struct CalendarDetailView: View {
    let calendar: GameCalendar

    var body: some View {
        List {
            ForEach(Array(calendar.days.enumerated()), id: \.offset) { _, day in
                Section {
                    ForEach(Array(day.events.enumerated()), id: \.offset) { _, event in
                        CalendarEventRowView(event: event)
                    }
                } header: {
                    SectionHeaderLabel(day.date.formatted(date: .abbreviated, time: .omitted))
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(Strings.WorldState.calendarHeader)
        .navigationBarTitleDisplayMode(.inline)
    }
}
