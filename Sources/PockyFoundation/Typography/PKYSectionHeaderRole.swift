public enum PKYSectionHeaderRole: Sendable {
    case page
    case group
    case label

    public var title: PKYTypographyRole {
        switch self {
        case .page: .title.bold
        case .group: .heading
        case .label: .caption.semibold
        }
    }

    public var detail: PKYTypographyRole {
        switch self {
        case .page: .body
        case .group: .supporting
        case .label: .caption
        }
    }
}
