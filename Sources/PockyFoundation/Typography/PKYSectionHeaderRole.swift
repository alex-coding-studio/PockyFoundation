/// Pairs a section title and trailing detail, such as a count or date, according to page structure.
///
/// Choose a role by position instead of selecting a separate size. A role keeps the same size
/// across pages. Navigation titles use ``PKYTypographyRole/pageTitle`` instead.
public enum PKYSectionHeaderRole: Sendable {
    /// Peer sections dividing a page into major areas, such as feature groups on a landing page.
    case page
    /// Content groups within grids or lists, often followed by a count or date.
    case group
    /// Compact, single-line groups within a card or tray.
    case label

    /// The typography role for the title.
    public var title: PKYTypographyRole {
        switch self {
        case .page: .title.bold
        case .group: .heading
        case .label: .caption.semibold
        }
    }

    /// The trailing detail role, below the title in emphasis; callers supply a secondary content color.
    public var detail: PKYTypographyRole {
        switch self {
        case .page: .body
        case .group: .supporting
        case .label: .caption
        }
    }
}
