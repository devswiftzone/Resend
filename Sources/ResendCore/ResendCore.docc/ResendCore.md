# ``ResendCore``

Core models and protocols for the Resend email API.

## Overview

ResendCore provides the foundational types, models, and protocols used across all Resend packages. It has no external dependencies and can be used independently.

## Topics

### Core Protocols

- ``HTTPClientProtocol``
- ``ResendClientProtocol``
- ``EmailClientProtocol``
- ``DomainClientProtocol``
- ``APIKeyClientProtocol``
- ``AudienceClientProtocol``
- ``ContactClientProtocol``
- ``BroadcastClientProtocol``
- ``WebhookClientProtocol``

### HTTP Types

- ``HTTPRequest``
- ``HTTPResponse``
- ``HTTPMethod``

### Pagination

- ``PaginatedSequence``

### Email Models

- ``ResendEmail``
- ``ResendEmailResponse``
- ``EmailAddress``
- ``EmailAttachment``
- ``EmailTag``

### Domain Models

- ``ResendDomain``
- ``DNSRecord``

### API Key Models

- ``ResendAPIKey``
- ``ResendAPIKeyListItem``

### Audience & Contact Models

- ``ResendAudience``
- ``ResendContact``

### Broadcast Models

- ``ResendBroadcast``
- ``ResendBroadcastSendResponse``

### Webhook Models

- ``ResendWebhook``

### Common Types

- ``ResendListResponse``
- ``ResendDeleteResponse``
- ``ResendBatchResponse``
- ``ResendBatchError``
- ``ResendRetrieveError``
