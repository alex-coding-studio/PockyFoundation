/// A background context and its existing nesting level, without a theme or resolved color.
public enum PKYBackgroundRole: Sendable {
    /// The background of ordinary, ungrouped content.
    case standard(PKYColorTheme.Background.Level)
    /// The background of grouped lists or forms.
    case grouped(PKYColorTheme.Background.Level)
}
