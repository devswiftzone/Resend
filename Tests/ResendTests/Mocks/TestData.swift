//
//  TestData.swift
//  ResendTests
//
//  Created by Test Suite
//

import Foundation
@testable import ResendCore

enum TestData {
    // MARK: - Email Test Data
    static let emailJSON = """
    {
        "object": "email",
        "id": "email_123",
        "created_at": "2025-01-01T00:00:00Z",
        "from": "sender@test.com",
        "to": ["recipient@test.com"],
        "subject": "Test Email",
        "html": "<p>Test</p>",
        "text": "Test"
    }
    """

    static let emailResponseJSON = """
    {
        "id": "email_123"
    }
    """

    static let batchResponseJSON = """
    {
        "data": [
            {"id": "email_1"},
            {"id": "email_2"}
        ],
        "errors": [
            {"index": 2, "message": "Invalid email"}
        ]
    }
    """

    // MARK: - Domain Test Data
    static let domainJSON = """
    {
        "id": "domain_123",
        "name": "test.com",
        "status": "verified",
        "created_at": "2025-01-01T00:00:00Z",
        "region": "us-east-1",
        "records": [
            {
                "record": "SPF",
                "name": "test.com",
                "type": "TXT",
                "value": "v=spf1 include:resend.com ~all",
                "status": "verified"
            }
        ]
    }
    """

    static let domainListJSON = """
    {
        "object": "list",
        "data": [
            {
                "id": "domain_1",
                "name": "test1.com",
                "status": "verified",
                "created_at": "2025-01-01T00:00:00Z",
                "region": "us-east-1"
            },
            {
                "id": "domain_2",
                "name": "test2.com",
                "status": "pending",
                "created_at": "2025-01-01T00:00:00Z",
                "region": "us-east-1"
            }
        ],
        "has_more": false
    }
    """

    // MARK: - API Key Test Data
    static let apiKeyJSON = """
    {
        "id": "key_123",
        "token": "re_test_token_abc123"
    }
    """

    static let apiKeyListJSON = """
    {
        "object": "list",
        "data": [
            {
                "id": "key_1",
                "name": "Production Key",
                "created_at": "2025-01-01T00:00:00Z"
            }
        ],
        "has_more": false
    }
    """

    // MARK: - Audience Test Data
    static let audienceJSON = """
    {
        "object": "audience",
        "id": "audience_123",
        "name": "Newsletter",
        "created_at": "2025-01-01T00:00:00Z"
    }
    """

    static let audienceListJSON = """
    {
        "object": "list",
        "data": [
            {
                "id": "audience_1",
                "name": "Newsletter",
                "created_at": "2025-01-01T00:00:00Z"
            }
        ],
        "has_more": false
    }
    """

    // MARK: - Contact Test Data
    static let contactJSON = """
    {
        "object": "contact",
        "id": "contact_123",
        "email": "user@test.com",
        "first_name": "John",
        "last_name": "Doe",
        "created_at": "2025-01-01T00:00:00Z",
        "unsubscribed": false
    }
    """

    static let contactListJSON = """
    {
        "object": "list",
        "data": [
            {
                "id": "contact_1",
                "email": "user1@test.com",
                "first_name": "John",
                "last_name": "Doe",
                "created_at": "2025-01-01T00:00:00Z",
                "unsubscribed": false
            }
        ],
        "has_more": false
    }
    """

    // MARK: - Broadcast Test Data
    static let broadcastJSON = """
    {
        "object": "broadcast",
        "id": "broadcast_123",
        "name": "Newsletter",
        "audience_id": "audience_123",
        "from": "newsletter@test.com",
        "subject": "Test Newsletter",
        "status": "draft",
        "created_at": "2025-01-01T00:00:00Z"
    }
    """

    static let broadcastSendResponseJSON = """
    {
        "id": "send_123"
    }
    """

    // MARK: - Error Test Data
    static let errorJSON = """
    {
        "statusCode": 400,
        "message": "Invalid email address",
        "name": "validation_error"
    }
    """

    static let deleteResponseJSON = """
    {
        "object": "domain",
        "id": "domain_123",
        "deleted": true
    }
    """
}
