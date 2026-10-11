//
//  WikiBrowserViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/11/26.
//

import Foundation
import Observation
import WebKit

@Observable
final class WikiBrowserViewModel: NSObject, WKNavigationDelegate {
    let webView = WKWebView()
    private let initialURL: URL
    private var hasLoaded = false

    private(set) var isLoading = false
    private(set) var canGoBack = false
    private(set) var canGoForward = false
    private(set) var errorMessage: String?

    init(url: URL) {
        initialURL = url
        super.init()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
    }

    func loadIfNeeded() {
        guard !hasLoaded else { return }
        hasLoaded = true
        webView.load(URLRequest(url: initialURL))
    }

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }

    func reload() {
        errorMessage = nil
        if webView.url == nil {
            webView.load(URLRequest(url: initialURL))
        } else {
            webView.reload()
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation?) {
        isLoading = true
        errorMessage = nil
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation?) {
        updateNavigationState()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        isLoading = false
        updateNavigationState()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation?, withError error: any Error) {
        handleFailure(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: any Error) {
        handleFailure(error)
    }

    private func handleFailure(_ error: any Error) {
        let nsError = error as NSError
        guard nsError.domain != NSURLErrorDomain || nsError.code != NSURLErrorCancelled else { return }
        isLoading = false
        errorMessage = error.localizedDescription
        updateNavigationState()
    }

    private func updateNavigationState() {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
    }
}
