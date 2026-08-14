//
//  ClaudeLoginView.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-08-10.
//

import SwiftUI
import WebKit

struct ClaudeLoginView: UIViewRepresentable {
   
    let onCapture: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: URL(string: "https://claude.ai/login")!))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture)
    }
    
    final class Coordinator: NSObject, WKNavigationDelegate {
        var onCapture: (String) -> Void
        
        private var captured = false
        
        init(onCapture: @escaping (String) -> Void) {
            self.onCapture = onCapture
        }
        
        // Called every time a page finishes loading — check the cookies for sessionKey.
              func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                  webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                      guard !self.captured,
                            let sessionKey = cookies.first(where: { $0.name == "sessionKey" })?.value
                      else { return }
                      self.captured = true
                      self.onCapture(sessionKey)
                  }
              }
          }
    }

