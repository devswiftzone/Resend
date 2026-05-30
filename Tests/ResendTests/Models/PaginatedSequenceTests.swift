//
//  PaginatedSequenceTests.swift
//  ResendTests
//

import Testing
import Foundation
@testable import ResendCore
@testable import ResendKit

private func makeItem(id: String) -> String {
    """
    {"id": "\(id)", "name": "item-\(id).com", "status": "verified", "created_at": "2025-01-01T00:00:00Z", "region": "us-east-1"}
    """
}

private func makePage(items: [String], hasMore: Bool) -> String {
    let dataJSON = items.joined(separator: ",\n")
    return """
    {"object": "list", "data": [\(dataJSON)], "has_more": \(hasMore)}
    """
}

@Suite("PaginatedSequence Tests")
struct PaginatedSequenceTests {

    @Test("Empty result")
    func testEmptyResult() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [], hasMore: false))

        let seq = PaginatedSequence<ResendDomain> { _ in
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        var items: [ResendDomain] = []
        for try await item in seq {
            items.append(item)
        }
        #expect(items.isEmpty)
        #expect(mock.requests.count == 1)
    }

    @Test("Single page, no more")
    func testSinglePage() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "1")], hasMore: false))

        let seq = PaginatedSequence<ResendDomain> { _ in
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        var items: [ResendDomain] = []
        for try await item in seq {
            items.append(item)
        }
        #expect(items.count == 1)
        #expect(items[0].id == "1")
        #expect(mock.requests.count == 1)
    }

    @Test("Two pages via explicit iterator")
    func testTwoPagesExplicitIterator() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "1")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "2")], hasMore: false))

        let seq = PaginatedSequence<ResendDomain> { _ in
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        let iter = seq.makeAsyncIterator()
        let item1 = try await iter.next()
        #expect(item1?.id == "1")

        let item2 = try await iter.next()
        #expect(item2?.id == "2")

        let item3 = try await iter.next()
        #expect(item3 == nil)

        #expect(mock.requests.count == 2)
    }

    @Test("Two pages via for-await")
    func testTwoPagesForAwait() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "1")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "2")], hasMore: false))

        let seq = PaginatedSequence<ResendDomain> { _ in
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        var items: [ResendDomain] = []
        for try await item in seq {
            items.append(item)
        }
        #expect(items.count == 2)
        #expect(items[0].id == "1")
        #expect(items[1].id == "2")
        #expect(mock.requests.count == 2)
    }

    @Test("Three pages")
    func testThreePages() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "1")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "2")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "3")], hasMore: false))

        let seq = PaginatedSequence<ResendDomain> { _ in
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        var items: [ResendDomain] = []
        for try await item in seq {
            items.append(item)
        }
        #expect(items.count == 3)
        #expect(items.map(\.id) == ["1", "2", "3"])
        #expect(mock.requests.count == 3)
    }

    @Test("Stops when hasMore is true but empty data")
    func testStopsOnEmptyData() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "1")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [], hasMore: true))

        let seq = PaginatedSequence<ResendDomain> { _ in
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        var items: [ResendDomain] = []
        for try await item in seq {
            items.append(item)
        }
        #expect(items.count == 1)
        #expect(mock.requests.count == 2)
    }

    @Test("Nil cursor on final page")
    func testNilCursorOnFinalPage() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "1")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "2")], hasMore: false))

        let seq = PaginatedSequence<ResendDomain> { _ in
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        let iter = seq.makeAsyncIterator()
        while (try await iter.next()) != nil { }
        #expect(mock.requests.count == 2)
    }

    @Test("Multiple items per page")
    func testMultipleItemsPerPage() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "1"), makeItem(id: "2")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "3")], hasMore: false))

        let seq = PaginatedSequence<ResendDomain> { _ in
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        var items: [ResendDomain] = []
        for try await item in seq {
            items.append(item)
        }
        #expect(items.count == 3)
        #expect(items.map(\.id) == ["1", "2", "3"])
        #expect(mock.requests.count == 2)
    }

    @Test("Propagates error from page fetch")
    func testErrorPropagation() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "1")], hasMore: true))
        mock.addError(URLError(.timedOut))

        let seq = PaginatedSequence<ResendDomain> { _ in
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        let iter = seq.makeAsyncIterator()
        let item1 = try await iter.next()
        #expect(item1?.id == "1")

        await #expect(throws: URLError.self) {
            try await iter.next()
        }

        #expect(mock.requests.count == 2)
    }

    @Test("Twelve items across 3 pages of 4 each")
    func testMultipleItemsEachPage() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "1"), makeItem(id: "2"), makeItem(id: "3"), makeItem(id: "4")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "5"), makeItem(id: "6"), makeItem(id: "7"), makeItem(id: "8")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "9"), makeItem(id: "10"), makeItem(id: "11"), makeItem(id: "12")], hasMore: false))

        let seq = PaginatedSequence<ResendDomain> { _ in
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        var items: [ResendDomain] = []
        for try await item in seq {
            items.append(item)
        }
        #expect(items.count == 12)
        #expect(items.map(\.id) == ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"])
        #expect(mock.requests.count == 3)
    }

    @Test("Large number of items across pages")
    func testLargeNumberOfPages() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "1")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "2")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "3")], hasMore: false))

        let seq = PaginatedSequence<ResendDomain> { _ in
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        var items: [ResendDomain] = []
        for try await item in seq {
            items.append(item)
        }
        #expect(items.count == 3)
        #expect(mock.requests.count == 3)
    }

    @Test("Multiple items per page with cursor tracking")
    func testMultipleItemsPerPageWithCursor() async throws {
        let mock = MockHTTPClient()
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "1"), makeItem(id: "2")], hasMore: true))
        mock.addResponse(statusCode: 200, body: makePage(items: [makeItem(id: "3"), makeItem(id: "4")], hasMore: false))

        var capturedCursors: [String?] = []
        let seq = PaginatedSequence<ResendDomain> { cursor in
            capturedCursors.append(cursor)
            let response = try await mock.execute(HTTPRequest(url: "https://test.com", method: .GET))
            let list = try JSONDecoder().decode(ResendListResponse<ResendDomain>.self, from: response.body!)
            return (list.data, list.hasMore, list.data.last?.id)
        }

        var items: [ResendDomain] = []
        for try await item in seq {
            items.append(item)
        }
        #expect(items.count == 4)
        #expect(capturedCursors == [nil, "2"])
        #expect(mock.requests.count == 2)
    }
}
