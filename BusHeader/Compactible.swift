public protocol Compactible {
    var sizeMode: CompactibleSizeMode { get set }
}

public enum CompactibleSizeMode {
    case regular
    case compact
}
