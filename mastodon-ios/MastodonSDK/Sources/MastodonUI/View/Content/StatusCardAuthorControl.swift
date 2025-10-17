import UIKit
import MastodonAsset
import MastodonSDK

class StatusCardAuthorControl: UIControl {
    let authorLabel: UILabel
    let avatarImage: AvatarImageView
    private let contentStackView: UIStackView

    public override init(frame: CGRect) {
        authorLabel = UILabel()
        authorLabel.textAlignment = .center
        authorLabel.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 15, weight: .semibold))
        authorLabel.textColor = .systemIndigo
        authorLabel.isUserInteractionEnabled = false

        avatarImage = AvatarImageView()
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.configure(cornerConfiguration: AvatarImageView.CornerConfiguration(corner: .fixed(radius: 4)))
        avatarImage.isUserInteractionEnabled = false

        contentStackView = UIStackView(arrangedSubviews: [avatarImage, authorLabel])
        contentStackView.alignment = .center
        contentStackView.spacing = 6
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.layoutMargins = UIEdgeInsets(horizontal: 6, vertical: 8)
        contentStackView.isUserInteractionEnabled = false

        super.init(frame: frame)

        addSubview(contentStackView)
        setupConstraints()
        backgroundColor = Asset.Colors.Button.userFollowing.color
        layer.cornerRadius = 6
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let verticalPadding: CGFloat = 4
    private let horizontalPadding: CGFloat = 6
    private func setupConstraints() {
        let constraints = [
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: verticalPadding),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: horizontalPadding),
            bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: verticalPadding),

            avatarImage.widthAnchor.constraint(equalToConstant: 20),
            avatarImage.widthAnchor.constraint(equalTo: avatarImage.heightAnchor).priority(.required),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    public func configure(with account: Mastodon.Entity.Account) {
        authorLabel.text = account.displayNameWithFallback
        avatarImage.configure(with: account.avatarImageURL())
    }
}
