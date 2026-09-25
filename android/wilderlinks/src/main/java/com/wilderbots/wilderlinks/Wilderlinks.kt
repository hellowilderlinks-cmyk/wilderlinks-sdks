package com.wilderbots.wilderlinks

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.net.Uri
import android.os.Build
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.util.Locale
import java.util.TimeZone
import java.util.UUID
import kotlin.coroutines.resume

data class WilderlinksConfig(
  val baseUrl: String,
  val domains: List<String>,
  /** Secret API key for trusted runtimes only. Never bundle an organization key in a mobile app. */
  val apiKey: String? = null
)

/** Input accepted by POST /api/v1/links. API-key operations belong on a trusted server. */
data class LinkCreateRequest(
  val defaultUrl: String,
  val domainId: String? = null,
  val appProfileId: String? = null,
  val pathPrefix: String? = null,
  val slug: String? = null,
  val title: String? = null,
  val rules: List<Map<String, Any?>>? = null,
  val splitTargets: List<Map<String, Any?>>? = null,
  val deepLinkPayload: Map<String, Any?>? = null,
  val utm: Map<String, Any?>? = null,
  val marketing: Map<String, Any?>? = null,
  val leadCapture: Map<String, Any?>? = null,
  val retargetingPixels: List<Map<String, Any?>>? = null,
  val ctaOverlay: Map<String, Any?>? = null,
  val password: String? = null,
  val startsAt: String? = null,
  val expiresAt: String? = null,
  val maxClicks: Int? = null,
  val tags: List<String>? = null,
  val preferShortDomain: Boolean? = null
) {
  internal fun toJson(): JSONObject = JSONObject().apply {
    put("defaultUrl", defaultUrl)
    domainId?.let { put("domainId", it) }
    appProfileId?.let { put("appProfileId", it) }
    pathPrefix?.let { put("pathPrefix", it) }
    slug?.let { put("slug", it) }
    title?.let { put("title", it) }
    rules?.let { put("rules", it) }
    splitTargets?.let { put("splitTargets", it) }
    deepLinkPayload?.let { put("deepLinkPayload", it) }
    utm?.let { put("utm", it) }
    marketing?.let { put("marketing", it) }
    leadCapture?.let { put("leadCapture", it) }
    retargetingPixels?.let { put("retargetingPixels", it) }
    ctaOverlay?.let { put("ctaOverlay", it) }
    password?.let { put("password", it) }
    startsAt?.let { put("startsAt", it) }
    expiresAt?.let { put("expiresAt", it) }
    maxClicks?.let { put("maxClicks", it) }
    tags?.let { put("tags", it) }
    preferShortDomain?.let { put("preferShortDomain", it) }
  }
}

data class CreatedLink(
  val id: String,
  val slug: String,
  val title: String?,
  val defaultUrl: String,
  val shortUrl: String,
  val isActive: Boolean,
  val clickCount: Int
) {
  companion object {
    internal fun fromJson(json: JSONObject) = CreatedLink(
      id = json.getString("_id"),
      slug = json.getString("slug"),
      title = json.optString("title").takeIf { it.isNotBlank() },
      defaultUrl = json.getString("defaultUrl"),
      shortUrl = json.getString("shortUrl"),
      isActive = json.optBoolean("isActive", true),
      clickCount = json.optInt("clickCount", 0)
    )
  }
}

class WilderlinksApiException(val statusCode: Int, message: String) : IOException(message)

data class ResolvedLink(
  val matched: Boolean,
  val openId: String? = null,
  val destinationUrl: String? = null,
  val deepLinkPayload: Map<String, Any?>? = null,
  val installAttributionProvider: String? = null,
  val error: String? = null
)

object Wilderlinks {
  private var config: WilderlinksConfig? = null

  fun init(config: WilderlinksConfig) {
    this.config = config
  }

  /**
   * Creates a link with POST /api/v1/links. Requires `links:write` and [WilderlinksConfig.apiKey].
   * Use only from a trusted server runtime; do not embed an organization key in an Android app.
   */
  suspend fun createLink(request: LinkCreateRequest): CreatedLink = createLinkBody(request.toJson())

  /** Flutter-compatible createLink arguments; use only from a trusted runtime. */
  suspend fun createLink(
    defaultUrl: String,
    domainId: String? = null,
    appProfileId: String? = null,
    pathPrefix: String? = null,
    slug: String? = null,
    title: String? = null,
    deepLinkPayload: Map<String, Any?>? = null,
    utm: Map<String, String>? = null,
    marketing: Map<String, Any?>? = null,
    leadCapture: Map<String, Any?>? = null,
    retargetingPixels: List<Map<String, Any?>>? = null,
    ctaOverlay: Map<String, Any?>? = null,
    password: String? = null,
    startsAt: String? = null,
    expiresAt: String? = null,
    maxClicks: Int? = null,
    tags: List<String>? = null,
    extra: Map<String, Any?>? = null
  ): CreatedLink {
    val body = LinkCreateRequest(
      defaultUrl = defaultUrl,
      domainId = domainId,
      appProfileId = appProfileId,
      pathPrefix = pathPrefix,
      slug = slug,
      title = title,
      deepLinkPayload = deepLinkPayload,
      utm = utm,
      marketing = marketing,
      leadCapture = leadCapture,
      retargetingPixels = retargetingPixels,
      ctaOverlay = ctaOverlay,
      password = password,
      startsAt = startsAt,
      expiresAt = expiresAt,
      maxClicks = maxClicks,
      tags = tags
    ).toJson()
    extra?.forEach { (key, value) -> body.put(key, value) }
    return createLinkBody(body)
  }

  private suspend fun createLinkBody(body: JSONObject): CreatedLink {
    val cfg = requireConfig()
    val key = cfg.apiKey?.takeIf { it.isNotBlank() }
      ?: throw IllegalStateException("API key is required to create links. Configure it only in a trusted runtime.")
    val (statusCode, response) = postApiKeyJson(
      "${trimSlash(cfg.baseUrl)}/api/v1/links",
      body.toString(),
      key
    )
    if (statusCode !in 200..299) {
      throw WilderlinksApiException(statusCode, response.optString("error").ifBlank { "Failed to create link ($statusCode)" })
    }
    return CreatedLink.fromJson(response)
  }

  /** Creates a deep link using the supplied API-key input. Trusted runtimes only. */
  suspend fun createDeepLink(request: LinkCreateRequest): CreatedLink = createLink(request)

  /** Flutter-compatible convenience wrapper around createLink. Trusted runtimes only. */
  suspend fun createDeepLink(
    defaultUrl: String,
    domainId: String? = null,
    appProfileId: String? = null,
    pathPrefix: String? = null,
    slug: String? = null,
    title: String? = null,
    deepLinkPayload: Map<String, Any?>? = null
  ): CreatedLink = createLink(
    defaultUrl = defaultUrl,
    domainId = domainId,
    appProfileId = appProfileId,
    pathPrefix = pathPrefix,
    slug = slug,
    title = title,
    deepLinkPayload = deepLinkPayload
  )

  /** Creates a link preferring the organization's short domain and returns its URL. Trusted runtimes only. */
  suspend fun createShortLink(
    defaultUrl: String,
    domainId: String? = null,
    appProfileId: String? = null,
    pathPrefix: String? = null,
    slug: String? = null
  ): String = createLink(
    LinkCreateRequest(
      defaultUrl = defaultUrl,
      domainId = domainId,
      appProfileId = appProfileId,
      pathPrefix = pathPrefix,
      slug = slug,
      preferShortDomain = true
    )
  ).shortUrl

  suspend fun handleIncomingUri(uri: Uri, context: Context? = null): ResolvedLink {
    val cfg = requireConfig()
    val deferredToken = uri.getQueryParameter("dl_match_token")
    if (deferredToken != null && deferredToken.matches(Regex("^[a-f0-9]{32}$"))) {
      val deferred = matchDeferredToken(cfg.baseUrl, deferredToken)
      if (deferred.matched) return deferred
    }

    if (!cfg.domains.contains(uri.host)) return ResolvedLink(matched = false)
    val segments = uri.pathSegments
    val slug = segments.lastOrNull().orEmpty()
    if (slug.isBlank()) return ResolvedLink(matched = false, error = "No slug in URI")

    val pathPrefix = if (segments.size > 1) "/${segments.dropLast(1).joinToString("/")}/" else null
    val tzOffsetMinutes = -(TimeZone.getDefault().getOffset(System.currentTimeMillis()) / 60000)
    val params = linkedMapOf(
      "domain" to uri.host.orEmpty(),
      "slug" to slug,
      "platform" to "android",
      "osVersion" to Build.VERSION.RELEASE.orEmpty(),
      "language" to Locale.getDefault().toLanguageTag(),
      "deviceVendor" to Build.MANUFACTURER.orEmpty(),
      "deviceModel" to Build.MODEL.orEmpty(),
      "timezoneOffsetMinutes" to tzOffsetMinutes.toString()
    )
    context?.resources?.configuration?.smallestScreenWidthDp?.let { widthDp ->
      params["deviceType"] = if (widthDp >= 600) "tablet" else "mobile"
    }
    context?.let { params["visitorId"] = visitorId(it.applicationContext) }
    if (pathPrefix != null) params["pathPrefix"] = pathPrefix
    uri.getQueryParameter("pw")?.let { params["password"] = it }

    return try {
      val response = getJson("${trimSlash(cfg.baseUrl)}/api/v1/resolve?${encodeQuery(params)}")
      if (response.optBoolean("matched", true) || response.has("destinationUrl")) response.toResolved(true)
      else ResolvedLink(matched = false, error = response.optString("error", "Resolve failed"))
    } catch (error: Exception) {
      ResolvedLink(matched = false, error = error.message ?: "Network error")
    }
  }

  suspend fun checkInstallReferrer(context: Context): ResolvedLink {
    val cfg = requireConfig()
    val referrer = readInstallReferrer(context.applicationContext) ?: return ResolvedLink(matched = false)
    val token = Regex("dl_match_token=([a-f0-9]{32})").find(referrer)?.groupValues?.get(1)
      ?: return ResolvedLink(matched = false)
    return matchDeferredToken(cfg.baseUrl, token)
  }

  private suspend fun readInstallReferrer(context: Context): String? =
    suspendCancellableCoroutine { continuation ->
      val client = InstallReferrerClient.newBuilder(context).build()
      try {
        client.startConnection(object : InstallReferrerStateListener {
          override fun onInstallReferrerSetupFinished(responseCode: Int) {
            val referrer = try {
              if (responseCode == InstallReferrerClient.InstallReferrerResponse.OK) {
                client.installReferrer?.installReferrer
              } else {
                null
              }
            } catch (error: Exception) {
              null
            } finally {
              client.endConnection()
            }
            if (continuation.isActive) continuation.resume(referrer)
          }

          override fun onInstallReferrerServiceDisconnected() {
            if (continuation.isActive) continuation.resume(null)
          }
        })
      } catch (error: Exception) {
        client.endConnection()
        if (continuation.isActive) {
          continuation.resume(null)
        }
      }
      continuation.invokeOnCancellation { client.endConnection() }
    }

  suspend fun checkDeferredInstall(context: Context): ResolvedLink {
    val cfg = requireConfig()
    val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
      ?: return ResolvedLink(matched = false, error = "Clipboard unavailable")
    val text = clipboard.primaryClip?.firstText(context).orEmpty()
    val token = Regex("dl_match_token=([a-f0-9]{32})").find(text)?.groupValues?.get(1)
      ?: return ResolvedLink(matched = false)
    return matchDeferredToken(cfg.baseUrl, token)
  }

  suspend fun matchDeferredToken(baseUrl: String, matchToken: String): ResolvedLink {
    return postMatch("${trimSlash(baseUrl)}/api/v1/match", mapOf("matchToken" to matchToken))
  }

  suspend fun matchInstallAttributionToken(
    baseUrl: String,
    installAttributionToken: String,
    provider: String = "app-store-campaign-token"
  ): ResolvedLink {
    return postMatch(
      "${trimSlash(baseUrl)}/api/v1/match/install-attribution",
      mapOf("installAttributionToken" to installAttributionToken, "provider" to provider)
    )
  }

  private fun requireConfig(): WilderlinksConfig =
    config ?: throw IllegalStateException("WilderLinks SDK is not initialized. Call Wilderlinks.init(...) first.")

  private fun visitorId(context: Context): String {
    val prefs = context.getSharedPreferences("wilderlinks", Context.MODE_PRIVATE)
    val existing = prefs.getString("visitor_id", null)
    if (existing != null && existing.matches(Regex("^[a-f0-9]{32}$"))) return existing
    val generated = UUID.randomUUID().toString().replace("-", "").lowercase(Locale.US)
    prefs.edit().putString("visitor_id", generated).apply()
    return generated
  }

  private fun ClipData.firstText(context: Context): String? =
    if (itemCount > 0) getItemAt(0).coerceToText(context)?.toString() else null

  private suspend fun postMatch(endpoint: String, body: Map<String, String>): ResolvedLink {
    return try {
      val response = postJson(endpoint, JSONObject(body).toString())
      if (response.optBoolean("matched", false)) response.toResolved(true)
      else ResolvedLink(matched = false, error = response.optString("error").takeIf { it.isNotBlank() })
    } catch (error: Exception) {
      ResolvedLink(matched = false, error = error.message ?: "Network error")
    }
  }

  private fun JSONObject.toResolved(matched: Boolean): ResolvedLink =
    ResolvedLink(
      matched = matched,
      openId = optString("openId").takeIf { it.isNotBlank() },
      destinationUrl = optString("destinationUrl").takeIf { it.isNotBlank() },
      deepLinkPayload = optJSONObject("deepLinkPayload")?.toMap(),
      installAttributionProvider = optString("installAttributionProvider").takeIf { it.isNotBlank() },
      error = optString("error").takeIf { it.isNotBlank() }
    )

  private fun JSONObject.toMap(): Map<String, Any?> =
    keys().asSequence().associateWith { key ->
      when (val value = get(key)) {
        is JSONObject -> value.toMap()
        JSONObject.NULL -> null
        else -> value
      }
    }

  private suspend fun getJson(endpoint: String): JSONObject = withContext(Dispatchers.IO) {
    val connection = URL(endpoint).openConnection() as HttpURLConnection
    connection.requestMethod = "GET"
    readJson(connection)
  }

  private suspend fun postJson(endpoint: String, json: String): JSONObject = withContext(Dispatchers.IO) {
    val connection = URL(endpoint).openConnection() as HttpURLConnection
    connection.requestMethod = "POST"
    connection.setRequestProperty("Content-Type", "application/json")
    connection.doOutput = true
    OutputStreamWriter(connection.outputStream).use { it.write(json) }
    readJson(connection)
  }

  private suspend fun postApiKeyJson(endpoint: String, json: String, apiKey: String): Pair<Int, JSONObject> =
    withContext(Dispatchers.IO) {
      val connection = URL(endpoint).openConnection() as HttpURLConnection
      try {
        connection.requestMethod = "POST"
        connection.setRequestProperty("Content-Type", "application/json")
        connection.setRequestProperty("Authorization", "ApiKey $apiKey")
        connection.doOutput = true
        OutputStreamWriter(connection.outputStream).use { it.write(json) }
        val statusCode = connection.responseCode
        val stream = if (statusCode in 200..299) connection.inputStream else connection.errorStream
        statusCode to JSONObject(stream?.bufferedReader()?.use { it.readText() }.orEmpty())
      } finally {
        connection.disconnect()
      }
    }

  private fun readJson(connection: HttpURLConnection): JSONObject {
    val stream = if (connection.responseCode in 200..299) connection.inputStream else connection.errorStream
    return JSONObject(stream.bufferedReader().use { it.readText() })
  }

  private fun encodeQuery(params: Map<String, String>): String =
    params.entries.joinToString("&") { (key, value) ->
      "${URLEncoder.encode(key, "UTF-8")}=${URLEncoder.encode(value, "UTF-8")}"
    }

  private fun trimSlash(value: String): String = value.trimEnd('/')
}
