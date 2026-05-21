import XCTest
@testable import Vapor
@testable import Resend

final class ResendTests: XCTestCase {
//    func testExample() throws {
//        // XCTest Documentation
//        // https://developer.apple.com/documentation/xctest
//        
//        // Defining Test Cases and Test Methods
//        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
//    }
//    
//    
//    func testSendEmail() throws {
//        let email = ResendEmail(from: .init(email: "reply@resend.dev", name: "Asiel Cabrera"), to: [.init(email: "cabrerasiel@gmail.com", name: "Asiel Cabrera")], subject: "subject", text: "texto del email")
//        
//        let app = Application()
//        //        app.resend.initialize()
//    }
    
    private var httpClient: HTTPClient!
    private var client: ResendClient!
    
    override func setUp() {
        httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        
        // TODO: Replace with your API key to test!
        _ = ResendClient(httpClient: httpClient, apiKey: "")
    }
    
    override func tearDown() async throws {
        try await httpClient.shutdown()
    }
    
    func test_sendEmail() async throws {
        
        
        // TODO: Replace from address with the email address associated with your verified Sender Identity!
        let email = ResendEmail(from: "reply@resend.dev", to: ["cabrerasiel@gmail.com"], subject: "subject", text: "texto del email")

        _ = try await ResendClient.email.send(email: email)
    }
    
//    func testRetrieve() async throws {
//        let email = try await ResendClient.email.retrieve(id: "86011f3e-f70c-4769-8092-053a4a2c0ddc")
//        print(email)
//    }
}
