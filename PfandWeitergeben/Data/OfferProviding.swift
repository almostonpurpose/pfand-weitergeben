import Foundation

@MainActor
protocol OfferProviding: AnyObject {
    var offers: [Offer] { get }
    func create(from draft: OfferDraft) throws -> Offer
    /// Accepts an open offer for the person on this device and returns the hand-over code.
    @discardableResult
    func claim(id: UUID) throws -> String
    /// Moves a claimed offer to collected. Only the correct hand-over code completes it.
    func markCollected(id: UUID, handoverCode: String) throws
    func cancel(id: UUID) throws
    func resetDemo()
}

enum OfferStoreError: LocalizedError, Equatable {
    case notFound
    case validation([OfferValidationIssue])
    case transition(OfferTransitionError)
    case wrongHandoverCode

    var errorDescription: String? {
        switch self {
        case .notFound: L10n.string("error.not_found")
        case .validation(let issues): issues.map(\.message).joined(separator: " ")
        case .transition: L10n.string("error.transition")
        case .wrongHandoverCode: L10n.string("error.handover_code")
        }
    }
}
