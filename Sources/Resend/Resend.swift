//
//  Resend.swift
//  Resend
//
//  Created by Asiel Cabrera Gonzalez on 12/2/23.
//

/// Re-export `ResendCore` and `ResendKit` for convenience.
///
/// Importing `Resend` gives you access to all public types from both modules:
///
/// ```swift
/// import Resend
///
/// let resend = ResendClient(apiKey: "re_...")
/// let email = ResendEmail(from: "...", to: ["..."], subject: "Hello", html: "<p>Hi</p>")
/// ```
@_exported import ResendCore
@_exported import ResendKit
