//
//  WikiBrowserView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/11/26.
//

import SwiftUI

struct WikiBrowserView: View {
    @State private var viewModel: WikiBrowserViewModel
    private let itemName: String
    private let onClose: () -> Void

    init(destination: WikiCoordinator.Destination, onClose: @escaping () -> Void) {
        itemName = destination.name
        self.onClose = onClose
        _viewModel = State(initialValue: WikiBrowserViewModel(url: destination.url))
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(itemName)
                        .font(.headline)
                    Spacer()
                    Button(Strings.Common.close, action: onClose)
                        .buttonStyle(AppGlassButtonStyle())
                }
                HStack {
                    navigationButton(Strings.Common.back, symbol: "chevron.left", action: viewModel.goBack)
                        .disabled(!viewModel.canGoBack)
                    navigationButton(Strings.Common.forward, symbol: "chevron.right", action: viewModel.goForward)
                        .disabled(!viewModel.canGoForward)
                    navigationButton(Strings.Main.refresh, symbol: "arrow.clockwise", action: viewModel.reload)
                    Spacer()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(AppGlassButtonStyle())
                .frame(minHeight: ListLayout.minimumRowHeight)
            }
            .padding(.horizontal)
            .padding(.top)
            Divider()
            EmbeddedWikiWebView(webView: viewModel.webView)
                .overlay {
                    if let errorMessage = viewModel.errorMessage {
                        ContentUnavailableView {
                            Label(Strings.Common.wikiLoadFailed, systemImage: "wifi.exclamationmark")
                        } description: {
                            Text(errorMessage)
                        } actions: {
                            Button(Strings.Main.refresh, action: viewModel.reload)
                        }
                        .background(Color.bg)
                    } else if viewModel.isLoading {
                        ProgressView()
                            .padding()
                            .appGlassSurface(cornerRadius: ListLayout.minimumRowHeight / 2)
                    }
                }
                .task {
                    viewModel.loadIfNeeded()
                }
        }
        .background(Color.bg)
        .wikiBrowserSize()
    }

    private func navigationButton(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .frame(minWidth: ListLayout.minimumRowHeight, minHeight: ListLayout.minimumRowHeight)
                .contentShape(Rectangle())
        }
    }
}
