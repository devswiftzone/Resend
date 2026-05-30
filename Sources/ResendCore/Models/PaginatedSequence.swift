//
//  PaginatedSequence.swift
//  ResendCore
//

import Foundation

/// An async sequence that fetches pages of data using cursor-based pagination.
///
/// Use `listAll()` on any resource client to obtain a `PaginatedSequence`,
/// then iterate over it with `for await`:
///
/// ```swift
/// for try await domain in resend.domains.listAll(limit: 10) {
///     print(domain.name)
/// }
/// ```
///
/// The sequence automatically fetches subsequent pages as needed,
/// using the cursor from each response to request the next page.
public final class PaginatedSequence<T: Codable & Sendable>: AsyncSequence, @unchecked Sendable {
    public typealias Element = T

    private let fetchPage: (String?) async throws -> (items: [T], hasMore: Bool, nextCursor: String?)

    /// Create a paginated sequence with a page-fetching closure.
    /// - Parameter fetchPage: A closure that takes an optional cursor and returns a page of items,
    ///   a flag indicating whether more pages exist, and the next cursor value.
    public init(
        fetchPage: @escaping (String?) async throws -> (items: [T], hasMore: Bool, nextCursor: String?)
    ) {
        self.fetchPage = fetchPage
    }

    public func makeAsyncIterator() -> Iterator {
        Iterator(fetchPage: fetchPage)
    }

    /// An iterator that fetches pages on demand as elements are consumed.
    public final class Iterator: AsyncIteratorProtocol {
        private let fetchPage: (String?) async throws -> (items: [T], hasMore: Bool, nextCursor: String?)
        private var queue: [T] = []
        private var cursor: String?
        private var isDone = false
        private var hasFetched = false

        fileprivate init(
            fetchPage: @escaping (String?) async throws -> (items: [T], hasMore: Bool, nextCursor: String?)
        ) {
            self.fetchPage = fetchPage
        }

        /// Advance to the next element, fetching a new page if the current queue is exhausted.
        /// - Returns: The next element, or `nil` when all pages have been consumed.
        public func next() async throws -> T? {
            if isDone && queue.isEmpty { return nil }

            if queue.isEmpty {
                let (items, hasMore, nextCursor) = try await fetchPage(cursor)
                hasFetched = true
                queue = items
                cursor = nextCursor
                if !hasMore || items.isEmpty {
                    isDone = true
                }
            }

            return queue.isEmpty ? nil : queue.removeFirst()
        }
    }
}
