//
//  URLSessionHTTPClientTests.swift
//  ResendTests
//
//  Created by Test Suite
//

import Testing
import Foundation
@testable import ResendKit
@testable import ResendCore

@Suite("URLSessionHTTPClient Tests")
struct URLSessionHTTPClientTests {

    @Test("URLSession HTTP client initialization")
    func testURLSessionHTTPClientInitialization() {
        let client = URLSessionHTTPClient()
        // Verify client was created successfully (compile-time check)
        _ = client
    }

    @Test("URLSession HTTP client with custom session")
    func testURLSessionHTTPClientWithCustomSession() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let client = URLSessionHTTPClient(session: session)
        // Verify client was created successfully (compile-time check)
        _ = client
    }

    // Note: Real network tests would require mocking URLSession
    // or using URLProtocol for more comprehensive testing
}
