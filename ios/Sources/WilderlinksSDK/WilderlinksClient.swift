import Foundation
#if canImport(UIKit)
import UIKit
#endif

public struct WilderlinksConfig: Sendable {
  public let baseURL: URL
  public let domains: Set<String>
  /// Secret API key for trusted runtimes only. Never bundle an organization key in an iOS app.
  public let apiKey: String?

  public init(baseURL: URL, domains: [String], apiKey: String? = nil) {
    self.baseURL = baseURL
    self.domains = Set(domains)
    self.apiKey = apiKey
  }
}

/// Input accepted by POST /api/v1/links. Use API-key operations only from a trusted server.
public struct LinkCreateRequest: Encodable, Sendable {
  public let defaultUrl: String
  public var domainId: String?
  public var appProfileId: String?
  public var pathPrefix: String?
  public var slug: String?
  public var title: String?
  public var rules: [JSONValue]?
  public var splitTargets: [JSONValue]?
  public var deepLinkPayload: [String: JSONValue]?
  public var utm: [String: String]?
  public var marketing: [String: JSONValue]?
  public var leadCapture: [String: JSONValue]?
  public var retargetingPixels: [JSONValue]?
  public var ctaOverlay: [String: JSONValue]?
  public var password: String?
  public var startsAt: String?
  public var expiresAt: String?
  public var maxClicks: Int?
  public var tags: [String]?
  public var preferShortDomain: Bool?

  public init(
    defaultUrl: String,
    domainId: String? = nil,
    appProfileId: String? = nil,
    pathPrefix: String? = nil,
    slug: String? = nil,
    title: String? = nil,
    rules: [JSONValue]? = nil,
    splitTargets: [JSONValue]? = nil,
    deepLinkPayload: [String: JSONValue]? = nil,
    utm: [String: String]? = nil,
    marketing: [String: JSONValue]? = nil,
    leadCapture: [String: JSONValue]? = nil,
    retargetingPixels: [JSONValue]? = nil,
    ctaOverlay: [String: JSONValue]? = nil,
    password: String? = nil,
    startsAt: String? = nil,
    expiresAt: String? = nil,
    maxClicks: Int? = nil,
    tags: [String]? = nil,
    preferShortDomain: Bool? = nil
  ) {
    self.defaultUrl = defaultUrl
    self.domainId = domainId
    self.appProfileId = appProfileId
    self.pathPrefix = pathPrefix
    self.slug = slug
    self.title = title
    self.rules = rules
    self.splitTargets = splitTargets
    self.deepLinkPayload = deepLinkPayload
    self.utm = utm
    self.marketing = marketing
    self.leadCapture = leadCapture
    self.retargetingPixels = retargetingPixels
    self.ctaOverlay = ctaOverlay
    self.password = password
    self.startsAt = startsAt
    self.expiresAt = expiresAt
    self.maxClicks = maxClicks
    self.tags = tags
    self.preferShortDomain = preferShortDomain
  }
}

public struct CreatedLink: Decodable, Sendable {
  public let id: String
  public let slug: String
  public let title: String?
  public let defaultUrl: String
  public let shortUrl: String
  public let clickCount: Int
  public let isActive: Bool

  enum CodingKeys: String, CodingKey {
    case id = "_id"
    case slug
    case title
    case defaultUrl
    case shortUrl
    case clickCount
    case isActive
  }
}

public enum WilderlinksAPIError: Error, LocalizedError, Sendable {
  case missingAPIKey
  case invalidResponse
  case httpStatus(Int, String)

  public var errorDescription: String? {
    switch self {
    case .missingAPIKey:
      return "API key is required to create links. Configure it only in a trusted runtime."
    case .invalidResponse:
      return "The WilderLinks API returned an invalid response."
    case let .httpStatus(statusCode, message):
      return message.isEmpty ? "WilderLinks API request failed (\(statusCode))." : message
    }
  }
}

public struct ResolvedLink: Decodable, Sendable {
  public let matched: Bool
  public let openId: String?
  public let destinationUrl: String?
  public let deepLinkPayload: [String: JSONValue]?
  public let installAttributionProvider: String?
  public let error: String?

  enum CodingKeys: String, CodingKey {
    case matched
    case openId
    case destinationUrl
    case deepLinkPayload
    case installAttributionProvider
    case error
  }

  public init(
    matched: Bool,
    openId: String? = nil,
    destinationUrl: String? = nil,
    deepLinkPayload: [String: JSONValue]? = nil,
    installAttributionProvider: String? = nil,
    error: String? = nil
  ) {
    self.matched = matched
    self.openId = openId
    self.destinationUrl = destinationUrl
    self.deepLinkPayload = deepLinkPayload
    self.installAttributionProvider = installAttributionProvider
    self.error = error
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    openId = try container.decodeIfPresent(String.self, forKey: .openId)
    destinationUrl = try container.decodeIfPresent(String.self, forKey: .destinationUrl)
    deepLinkPayload = try container.decodeIfPresent([String: JSONValue].self, forKey: .deepLinkPayload)
    installAttributionProvider = try container.decodeIfPresent(String.self, forKey: .installAttributionProvider)
    error = try container.decodeIfPresent(String.self, forKey: .error)
    matched = try container.decodeIfPresent(Bool.self, forKey: .matched) ?? (destinationUrl != nil || deepLinkPayload != nil)
  }

  public static func notMatched(_ error: String? = nil) -> ResolvedLink {
    ResolvedLink(matched: false, openId: nil, destinationUrl: nil, deepLinkPayload: nil, installAttributionProvider: nil, error: error)
  }
}

public enum JSONValue: Codable, Sendable {
  case string(String)
  case number(Double)
  case bool(Bool)
  case object([String: JSONValue])
  case array([JSONValue])
  case null

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() {
      self = .null
    } else if let value = try? container.decode(Bool.self) {
      self = .bool(value)
    } else if let value = try? container.decode(Double.self) {
      self = .number(value)
    } else if let value = try? container.decode(String.self) {
      self = .string(value)
    } else if let value = try? container.decode([String: JSONValue].self) {
      self = .object(value)
    } else {
      self = .array(try container.decode([JSONValue].self))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case let .string(value): try container.encode(value)
    case let .number(value): try container.encode(value)
    case let .bool(value): try container.encode(value)
    case let .object(value): try container.encode(value)
    case let .array(value): try container.encode(value)
    case .null: try container.encodeNil()
    }
  }
}

public final class WilderlinksClient: @unchecked Sendable {
  private let config: WilderlinksConfig
  private let session: URLSession
  private let decoder = JSONDecoder()
  private static let visitorDefaultsKey = "com.wilderbots.wilderlinks.visitorId"

  public init(config: WilderlinksConfig, session: URLSession = .shared) {
    self.config = config
    self.session = session
  }

  public func handleIncomingURL(_ url: URL) async -> ResolvedLink {
    if let token = URLComponents(url: url, resolvingAgainstBaseURL: false)?
      .queryItems?
      .first(where: { $0.name == "dl_match_token" })?
      .value,
      token.range(of: "^[a-f0-9]{32}$", options: .regularExpression) != nil {
      let deferred = await matchDeferredToken(token)
      if deferred.matched { return deferred }
    }

    guard let host = url.host, config.domains.contains(host) else {
      return .notMatched()
    }

    let segments = url.pathComponents.filter { $0 != "/" }
    guard let slug = segments.last, !slug.isEmpty else {
      return .notMatched("No slug in URL")
    }

    var items = [
      URLQueryItem(name: "domain", value: host),
      URLQueryItem(name: "slug", value: slug),
      URLQueryItem(name: "platform", value: "ios"),
      URLQueryItem(name: "visitorId", value: Self.visitorId()),
      URLQueryItem(name: "osVersion", value: ProcessInfo.processInfo.operatingSystemVersionString),
      URLQueryItem(name: "language", value: Locale.current.identifier.replacingOccurrences(of: "_", with: "-")),
      URLQueryItem(name: "timezoneOffsetMinutes", value: String(-(TimeZone.current.secondsFromGMT() / 60))),
    ]
    items.append(contentsOf: deviceSignalItems())

    if segments.count > 1 {
      items.append(URLQueryItem(name: "pathPrefix", value: "/\(segments.dropLast().joined(separator: "/"))/"))
    }
    if let password = URLComponents(url: url, resolvingAgainstBaseURL: false)?
      .queryItems?
      .first(where: { $0.name == "pw" })?
      .value {
      items.append(URLQueryItem(name: "password", value: password))
    }

    var components = URLComponents(url: endpoint("/api/v1/resolve"), resolvingAgainstBaseURL: false)
    components?.queryItems = items
    guard let resolveURL = components?.url else { return .notMatched("Invalid resolve URL") }
    return await get(resolveURL)
  }

  /// Creates a link with POST /api/v1/links. Requires `links:write` and a configured API key.
  /// Use only from a trusted server runtime; do not bundle an organization key in an iOS app.
  public func createLink(_ input: LinkCreateRequest) async throws -> CreatedLink {
    try await createLink(body: JSONEncoder().encode(input))
  }

  /// Flutter-compatible createLink arguments. Use only from a trusted server runtime.
  public func createLink(
    defaultUrl: String,
    domainId: String? = nil,
    appProfileId: String? = nil,
    pathPrefix: String? = nil,
    slug: String? = nil,
    title: String? = nil,
    deepLinkPayload: [String: JSONValue]? = nil,
    utm: [String: String]? = nil,
    marketing: [String: JSONValue]? = nil,
    leadCapture: [String: JSONValue]? = nil,
    retargetingPixels: [JSONValue]? = nil,
    ctaOverlay: [String: JSONValue]? = nil,
    password: String? = nil,
    startsAt: String? = nil,
    expiresAt: String? = nil,
    maxClicks: Int? = nil,
    tags: [String]? = nil,
    extra: [String: JSONValue]? = nil
  ) async throws -> CreatedLink {
    let input = LinkCreateRequest(
      defaultUrl: defaultUrl,
      domainId: domainId,
      appProfileId: appProfileId,
      pathPrefix: pathPrefix,
      slug: slug,
      title: title,
      deepLinkPayload: deepLinkPayload,
      utm: utm,
      marketing: marketing,
      leadCapture: leadCapture,
      retargetingPixels: retargetingPixels,
      ctaOverlay: ctaOverlay,
      password: password,
      startsAt: startsAt,
      expiresAt: expiresAt,
      maxClicks: maxClicks,
      tags: tags
    )
    var body = try JSONSerialization.jsonObject(with: JSONEncoder().encode(input)) as? [String: Any] ?? [:]
    for (key, value) in extra ?? [:] {
      let valueData = try JSONEncoder().encode(value)
      body[key] = try JSONSerialization.jsonObject(with: valueData, options: .fragmentsAllowed)
    }
    let bodyData = try JSONSerialization.data(withJSONObject: body)
    return try await createLink(body: bodyData)
  }

  private func createLink(body: Data) async throws -> CreatedLink {
    guard let apiKey = config.apiKey, !apiKey.isEmpty else {
      throw WilderlinksAPIError.missingAPIKey
    }

    var request = URLRequest(url: endpoint("/api/v1/links"))
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("ApiKey \(apiKey)", forHTTPHeaderField: "Authorization")
    request.httpBody = body

    let (data, response) = try await session.data(for: request)
    guard let response = response as? HTTPURLResponse else {
      throw WilderlinksAPIError.invalidResponse
    }
    guard (200..<300).contains(response.statusCode) else {
      let body = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
      throw WilderlinksAPIError.httpStatus(response.statusCode, body?["error"] as? String ?? "")
    }
    do {
      return try decoder.decode(CreatedLink.self, from: data)
    } catch {
      throw WilderlinksAPIError.invalidResponse
    }
  }

  /// Convenience wrapper around createLink(_:). Trusted server runtimes only.
  public func createDeepLink(_ input: LinkCreateRequest) async throws -> CreatedLink {
    try await createLink(input)
  }

  /// Flutter-compatible convenience wrapper around createLink(defaultUrl:...). Trusted servers only.
  public func createDeepLink(
    defaultUrl: String,
    domainId: String? = nil,
    appProfileId: String? = nil,
    pathPrefix: String? = nil,
    slug: String? = nil,
    title: String? = nil,
    deepLinkPayload: [String: JSONValue]? = nil
  ) async throws -> CreatedLink {
    try await createLink(
      defaultUrl: defaultUrl,
      domainId: domainId,
      appProfileId: appProfileId,
      pathPrefix: pathPrefix,
      slug: slug,
      title: title,
      deepLinkPayload: deepLinkPayload
    )
  }

  /// Creates a link preferring the organization's short domain and returns its URL. Trusted runtimes only.
  public func createShortLink(
    defaultUrl: String,
    domainId: String? = nil,
    appProfileId: String? = nil,
    pathPrefix: String? = nil,
    slug: String? = nil
  ) async throws -> String {
    let input = LinkCreateRequest(
      defaultUrl: defaultUrl,
      domainId: domainId,
      appProfileId: appProfileId,
      pathPrefix: pathPrefix,
      slug: slug,
      preferShortDomain: true
    )
    return try await createLink(input).shortUrl
  }

  public func matchDeferredToken(_ matchToken: String) async -> ResolvedLink {
    await post(path: "/api/v1/match", body: ["matchToken": matchToken])
  }

  private static func visitorId() -> String {
    if let existing = UserDefaults.standard.string(forKey: visitorDefaultsKey),
      existing.range(of: "^[a-f0-9]{32}$", options: .regularExpression) != nil {
      return existing
    }
    let generated = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    UserDefaults.standard.set(generated, forKey: visitorDefaultsKey)
    return generated
  }

  private func deviceSignalItems() -> [URLQueryItem] {
    #if canImport(UIKit)
    let idiomIsPad = UIDevice.current.userInterfaceIdiom == .pad
    return [
      URLQueryItem(name: "deviceType", value: idiomIsPad ? "tablet" : "mobile"),
      URLQueryItem(name: "deviceVendor", value: "Apple"),
      URLQueryItem(name: "deviceModel", value: UIDevice.current.model),
    ]
    #else
    return []
    #endif
  }

  public func checkDeferredInstall() async -> ResolvedLink {
    #if canImport(UIKit)
    guard UIPasteboard.general.hasStrings, let text = UIPasteboard.general.string else {
      return .notMatched()
    }
    guard let match = text.range(of: "dl_match_token=[a-f0-9]{32}", options: .regularExpression) else {
      return .notMatched()
    }
    let token = String(text[match]).replacingOccurrences(of: "dl_match_token=", with: "")
    return await matchDeferredToken(token)
    #else
    return .notMatched("Pasteboard unavailable on this platform")
    #endif
  }

  public func matchInstallAttributionToken(
    _ installAttributionToken: String,
    provider: String = "app-store-campaign-token"
  ) async -> ResolvedLink {
    await post(
      path: "/api/v1/match/install-attribution",
      body: ["installAttributionToken": installAttributionToken, "provider": provider]
    )
  }

  private func get(_ url: URL) async -> ResolvedLink {
    do {
      let (data, _) = try await session.data(from: url)
      return try decoder.decode(ResolvedLink.self, from: data)
    } catch {
      return .notMatched(error.localizedDescription)
    }
  }

  private func post(path: String, body: [String: String]) async -> ResolvedLink {
    do {
      var request = URLRequest(url: endpoint(path))
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try JSONEncoder().encode(body)
      let (data, _) = try await session.data(for: request)
      return try decoder.decode(ResolvedLink.self, from: data)
    } catch {
      return .notMatched(error.localizedDescription)
    }
  }

  private func endpoint(_ path: String) -> URL {
    let base = config.baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    return URL(string: "\(base)/\(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))")!
  }
}
