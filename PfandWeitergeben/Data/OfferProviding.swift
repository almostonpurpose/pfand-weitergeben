import Foundation

@MainActor
protocol OfferProviding: AnyObject {
    var offers: [Offer] { get }
    func create(from draft: OfferDraft) throws -> Offer
    func claim(id: UUID, collectorName: String) throws
    func markCollected(id: UUID) throws
    func cancel(id: UUID) throws
    func resetDemo()
}

enum OfferStoreError: LocalizedError, Equatable {
    case notFound
    case validation([OfferValidationIssue])
    case transition(OfferTransitionError)

    var errorDescription: String? {
        switch self {
        case .notFound: L10n.string("error.not_found")
        case .validation(let issues): issues.map(\.message).joined(separator: " ")
        case .transition: L10n.string("error.transition")
        }
    }
}
