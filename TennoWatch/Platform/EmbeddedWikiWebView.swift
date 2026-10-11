//
//  EmbeddedWikiWebView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/11/26.
//

import SwiftUI
import WebKit

#if os(macOS)
private typealias WikiWebViewRepresentable = NSViewRepresentable
#else
private typealias WikiWebViewRepresentable = UIViewRepresentable
#endif

struct EmbeddedWikiWebView: WikiWebViewRepresentable {
    let webView: WKWebView

    #if os(macOS)
    func makeNSView(context: Context) -> WKWebView {
        webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
    #else
    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
    #endif
}

extension View {
    func wikiBrowserSize() -> some View {
        #if os(macOS)
        frame(minWidth: Layout.minimumWidth, idealWidth: Layout.idealWidth,
              minHeight: Layout.minimumHeight, idealHeight: Layout.idealHeight)
        #else
        self
        #endif
    }
}

private struct Layout {
    static let minimumWidth: CGFloat = 600
    static let idealWidth: CGFloat = 900
    static let minimumHeight: CGFloat = 500
    static let idealHeight: CGFloat = 700
}
