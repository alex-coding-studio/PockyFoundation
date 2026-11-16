#if os(iOS) && DEBUG
    import UIKit

    @available(iOS 26.0, *)
    private final class PKYLayoutWidthRulesPreviewController: UIViewController {
        private let card = UIView()
        private let caption = UILabel()

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemGroupedBackground

            card.backgroundColor = .secondarySystemGroupedBackground
            card.translatesAutoresizingMaskIntoConstraints = false
            card.pkyApplyConcentricCorners(minimum: PKYShape.Radius.card)
            view.addSubview(card)

            caption.numberOfLines = 0
            caption.font = .preferredFont(forTextStyle: .body)
            caption.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(caption)

            let inset = PKYLayout.Inset.container()
            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: view.pkyContentWidthGuide.topAnchor),
                caption.topAnchor.constraint(equalTo: card.topAnchor, constant: inset),
                caption.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -inset),
                caption.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: inset),
                caption.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -inset),
            ])
            PKYLayout.ContentWidth.pin(
                card,
                in: view,
                leading: view.layoutMarginsGuide.leadingAnchor,
                trailing: view.layoutMarginsGuide.trailingAnchor,
                inset: 0
            )
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            let available = view.layoutMarginsGuide.layoutFrame.size
            let widthClass = PKYLayout.WidthClass(availableWidth: available.width)
            let split = PKYLayout.Split(stackedHeight: 600, available: available)
            let text = """
            Available \(Int(available.width)) × \(Int(available.height))
            Width Class: \(widthClass)
            Split for 600 pt stacked content: \(split)
            Card width: \(Int(card.bounds.width)) (maximum \(Int(PKYLayout.ContentWidth.maximum)))
            """
            if caption.text != text {
                caption.text = text
            }
        }
    }

    @available(iOS 26.0, *)
    #Preview("Width Rules") {
        PKYLayoutWidthRulesPreviewController()
    }
#endif
