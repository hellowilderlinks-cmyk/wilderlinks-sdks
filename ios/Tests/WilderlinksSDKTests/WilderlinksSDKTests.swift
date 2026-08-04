import XCTest
@testable import WilderlinksSDK

final class WilderlinksSDKTests: XCTestCase {
  override func tearDown() {
    MockURLProtocol.requestHandler = nil
    super.tearDown()
  }

  func testNotMatchedFactory() {
    let result = ResolvedLink.notMatched("No link")
    XCTAssertFalse(result.matched)
    XCTAssertEqual(result.error, "No link")
  }

  func testHandleIncomingURLResolvesPrefixedUniversalLink() async {
    let session = mockSession { request in
      let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
      XCTAssertEqual(components.path, "/api/v1/resolve")

      let query = Dictionary(uniqueKeysWithValues: components.queryItems!.map { ($0.name, $0.value ?? "") })
      XCTAssertEqual(query["domain"], "go.yourbrand.com")
      XCTAssertEqual(query["slug"], "promo")
      XCTAssertEqual(query["pathPrefix"], "/x4I9/")
      XCTAssertEqual(query["platform"], "ios")
      XCTAssertEqual(query["password"], "secret")

      return jsonResponse("""
      {
        "matched": true,
        "openId": "open_123",
        "destinationUrl": "https://example.com/promo",
        "deepLinkPayload": { "screen": "offer", "offerId": "spring24" }
      }
      """)
    }

    let client = WilderlinksClient(
      config: WilderlinksConfig(
        baseURL: URL(string: "https://api.wilderlinks.space")!,
        domains: ["go.yourbrand.com"]
      ),
      session: session
    )

    let result = await client.handleIncomingURL(URL(string: "https://go.yourbrand.com/x4I9/promo?pw=secret")!)

    XCTAssertTrue(result.matched)
    XCTAssertEqual(result.openId, "open_123")
    XCTAssertEqual(result.destinationUrl, "https://example.com/promo")
    if case .string("offer") = result.deepLinkPayload?["screen"] {
      XCTAssertTrue(true)
    } else {
      XCTFail("Expected deepLinkPayload.screen to be offer")
    }
  }

  func testHandleIncomingURLIgnoresUnknownDomain() async {
    let client = WilderlinksClient(
      config: WilderlinksConfig(
        baseURL: URL(string: "https://api.wilderlinks.space")!,
        domains: ["go.yourbrand.com"]
      ),
      session: mockSession { _ in XCTFail("Unknown domains should not call the API"); return jsonResponse("{}") }
    )

    let result = await client.handleIncomingURL(URL(string: "https://other.example.com/promo")!)

    XCTAssertFalse(result.matched)
  }

  func testMatchDeferredTokenPostsToken() async {
    let session = mockSession { request in
      XCTAssertEqual(request.url?.path, "/api/v1/match")
      XCTAssertEqual(request.httpMethod, "POST")
      XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")

      let body = try! JSONSerialization.jsonObject(with: requestBodyData(request)) as! [String: String]
      XCTAssertEqual(body["matchToken"], "0123456789abcdef0123456789abcdef")

      return jsonResponse("""
      {
        "matched": true,
        "installAttributionProvider": "clipboard",
        "destinationUrl": "https://example.com/install"
      }
      """)
    }

    let client = WilderlinksClient(
      config: WilderlinksConfig(
        baseURL: URL(string: "https://api.wilderlinks.space")!,
        domains: ["go.yourbrand.com"]
      ),
      session: session
    )

    let result = await client.matchDeferredToken("0123456789abcdef0123456789abcdef")

    XCTAssertTrue(result.matched)
    XCTAssertEqual(result.installAttributionProvider, "clipboard")
    XCTAssertEqual(result.destinationUrl, "https://example.com/install")
  }

  func testMatchInstallAttributionTokenPostsProvider() async {
    let session = mockSession { request in
      XCTAssertEqual(request.url?.path, "/api/v1/match/install-attribution")

      let body = try! JSONSerialization.jsonObject(with: requestBodyData(request)) as! [String: String]
      XCTAssertEqual(body["installAttributionToken"], "wl_token")
      XCTAssertEqual(body["provider"], "app-store-campaign-token")

      return jsonResponse("""
      {
        "matched": true,
        "installAttributionProvider": "app-store-campaign-token"
      }
      """)
    }

    let client = WilderlinksClient(
      config: WilderlinksConfig(
        baseURL: URL(string: "https://api.wilderlinks.space")!,
        domains: ["go.yourbrand.com"]
      ),
      session: session
    )

    let result = await client.matchInstallAttributionToken("wl_token")

    XCTAssertTrue(result.matched)
    XCTAssertEqual(result.installAttributionProvider, "app-store-campaign-token")
  }
}

private final class MockURLProtocol: URLProtocol {
  static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    guard let handler = Self.requestHandler else {
      client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
      return
    }

    do {
      let (response, data) = try handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}
}

private func mockSession(_ handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data)) -> URLSession {
  MockURLProtocol.requestHandler = handler
  let configuration = URLSessionConfiguration.ephemeral
  configuration.protocolClasses = [MockURLProtocol.self]
  return URLSession(configuration: configuration)
}

private func jsonResponse(_ body: String, statusCode: Int = 200) -> (HTTPURLResponse, Data) {
  let response = HTTPURLResponse(
    url: URL(string: "https://api.wilderlinks.space")!,
    statusCode: statusCode,
    httpVersion: nil,
    headerFields: ["Content-Type": "application/json"]
  )!
  return (response, Data(body.utf8))
}

private func requestBodyData(_ request: URLRequest) -> Data {
  if let body = request.httpBody {
    return body
  }

  guard let stream = request.httpBodyStream else {
    return Data()
  }

  stream.open()
  defer { stream.close() }

  var data = Data()
  let bufferSize = 1024
  let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
  defer { buffer.deallocate() }

  while stream.hasBytesAvailable {
    let count = stream.read(buffer, maxLength: bufferSize)
    if count <= 0 {
      break
    }
    data.append(buffer, count: count)
  }

  return data
}
