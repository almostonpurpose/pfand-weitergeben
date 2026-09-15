# Backend contract boundary

`OfferProviding` is the app-facing port. A later `CloudflareOfferStore` should preserve its semantics while adding async network operations and authenticated actor context.

`ReturnPointProviding` is a separate read-only port for public return infrastructure. The bundled `BundledBerlinReturnPointProvider` decodes a dated OpenStreetMap/ODbL snapshot. A production provider may refresh the same categories from a licensed source without changing the map or list UI.

## Required guarantees

- Claim is atomic: exactly one collector can move an open offer to claimed.
- The device-local participant identifier (`LocalIdentity.id`) is the placeholder for an authenticated actor. The server issues the four-digit hand-over code at claim time, returns it only to the collector, and validates it on collect; the owner never receives it through the API.
- The public response never contains a private residence or precise owner coordinate; only a rounded discovery area is public.
- A claim-specific home address or agreed hand-off location is visible only to the offer owner and accepted collector.
- Every status mutation records actor, server timestamp, previous state and next state.
- Reports are immutable submissions with a separate moderation status.
- Cancellation is allowed only from open or claimed; collection only from claimed.
- API retries use idempotency keys.
- The current photo estimate never leaves the device and is not part of the offer payload. Any future image upload requires a separate reviewed contract, consent, retention and moderation design.
- Every return-point response declares source attribution, licence/terms, last update time and whether the data is sample or production data.
- Return-point data must not claim supermarket completeness, accepted container types, real-time opening or bin availability unless an authoritative current source explicitly supports those fields.
- Public return-point coordinates stay separate from private hand-off data and do not justify exposing an offer owner's precise coordinate.

## Suggested routes

| Method | Route | Purpose |
|---|---|---|
| GET | `/offers?near=…` | public, rounded-area discovery |
| POST | `/offers` | create an offer |
| GET | `/offers/:id` | public detail or actor-authorised hand-off detail |
| POST | `/offers/:id/claim` | atomic claim |
| POST | `/offers/:id/collect` | mark collected; body carries the hand-over code |
| POST | `/offers/:id/cancel` | cancel |
| POST | `/offers/:id/reports` | submit safety/moderation report |
| GET | `/activity` | actor's offers and claims |
| GET | `/return-points?near=…&kinds=supermarket,glass` | licensed public POIs with attribution and freshness metadata |

The production protocol should become `async throws`; the synchronous shape is intentional for an immediately runnable, credential-free prototype.
