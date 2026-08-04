export { init as initWilderlinks, handleIncomingUrl as handleWilderlinksUrl, checkDeferredInstall as checkWilderlinksInstall, createDeepLink as createWildlink } from './linking';
export {
  init,
  handleIncomingUrl,
  checkDeferredInstall,
  matchDeferredToken,
  matchInstallAttributionToken,
  createLink,
  createShortLink,
  createDeepLink,
  trackEvent,
} from './linking';
export type { WilderlinksConfig, ResolvedLink, CreateLinkInput, LinkResponse, RoutingRuleInput, UTMParams, MarketingParams, LeadCaptureConfig, RetargetingPixel, CtaOverlayConfig, TrackEventInput, TrackEventResponse } from './linking';
export { useWilderlinks } from './useWilderlinks';
