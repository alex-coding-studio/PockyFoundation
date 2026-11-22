import Foundation

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public struct PKYFontFamily: Sendable {
    enum Storage: Sendable {
        case system
        case custom([PKYFontFaceKey: String])
    }

    public static let system = PKYFontFamily(storage: .system)

    let storage: Storage

    private init(storage: Storage) {
        self.storage = storage
    }

    public static func custom(
        regular: String,
        medium: String? = nil,
        semibold: String? = nil,
        bold: String? = nil,
        italic: String? = nil,
        mediumItalic: String? = nil,
        semiboldItalic: String? = nil,
        boldItalic: String? = nil
    ) -> PKYFontFamily {
        var faces = [PKYFontFaceKey(weight: .regular, isItalic: false): regular]
        faces[PKYFontFaceKey(weight: .medium, isItalic: false)] = medium
        faces[PKYFontFaceKey(weight: .semibold, isItalic: false)] = semibold
        faces[PKYFontFaceKey(weight: .bold, isItalic: false)] = bold
        faces[PKYFontFaceKey(weight: .regular, isItalic: true)] = italic
        faces[PKYFontFaceKey(weight: .medium, isItalic: true)] = mediumItalic
        faces[PKYFontFaceKey(weight: .semibold, isItalic: true)] = semiboldItalic
        faces[PKYFontFaceKey(weight: .bold, isItalic: true)] = boldItalic
        return PKYFontFamily(storage: .custom(faces))
    }

    func resolvedFace(
        weight: PKYFontWeight,
        isItalic: Bool,
        size: CGFloat,
        boldText: Bool = false
    ) -> PKYResolvedFontFace {
        let weight = boldText ? weight.nextHeavier : weight
        switch storage {
        case .system:
            return .system(weight: weight, isItalic: isItalic)
        case let .custom(faces):
            let requested = PKYFontFaceKey(weight: weight, isItalic: isItalic)
            if let name = loadableName(for: requested, in: faces, size: size) {
                return .custom(name: name)
            }

            if isItalic {
                let upright = PKYFontFaceKey(weight: weight, isItalic: false)
                if let name = loadableName(for: upright, in: faces, size: size) {
                    return .custom(name: name)
                }
            }

            let nearestUpright = faces.keys
                .filter { !$0.isItalic }
                .sorted {
                    let leftWeight = $0.weight.rank
                    let rightWeight = $1.weight.rank
                    let leftMeetsWeight = leftWeight >= weight.rank
                    let rightMeetsWeight = rightWeight >= weight.rank
                    if boldText, leftMeetsWeight != rightMeetsWeight {
                        return leftMeetsWeight
                    }
                    let leftDistance = abs(leftWeight - weight.rank)
                    let rightDistance = abs(rightWeight - weight.rank)
                    return (leftDistance, leftWeight) < (rightDistance, rightWeight)
                }
            for candidate in nearestUpright {
                if let name = loadableName(for: candidate, in: faces, size: size) {
                    return .custom(name: name)
                }
            }

            return .system(weight: weight, isItalic: isItalic)
        }
    }

    private func loadableName(
        for key: PKYFontFaceKey,
        in faces: [PKYFontFaceKey: String],
        size: CGFloat
    ) -> String? {
        #if os(iOS)
            guard let name = faces[key], UIFont(name: name, size: size) != nil else {
                return nil
            }
            return name
        #elseif os(macOS)
            guard let name = faces[key], NSFont(name: name, size: size) != nil else {
                return nil
            }
            return name
        #endif
    }
}

struct PKYFontFaceKey: Hashable, Sendable {
    let weight: PKYFontWeight
    let isItalic: Bool
}

enum PKYResolvedFontFace: Sendable {
    case system(weight: PKYFontWeight, isItalic: Bool)
    case custom(name: String)
}
