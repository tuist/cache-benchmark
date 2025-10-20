//
//  MastodonServerRulesViewController.swift
//  Mastodon
//
//  Created by MainasuK Cirno on 2021-2-22.
//

import UIKit
import Combine
import MastodonSDK
import SafariServices
import MetaTextKit
import MastodonAsset
import MastodonCore
import MastodonLocalization
import SwiftUI

struct MastodonServerRulesView: View {
    class ViewModel: ObservableObject {
        let disclaimer: LocalizedStringKey?
        let rules: [Mastodon.Entity.Instance.Rule]
        var onAgree: (() -> Void)?
        var onDisagree: (() -> Void)?
        
        init(disclaimer: LocalizedStringKey?, rules: [Mastodon.Entity.Instance.Rule], onAgree: (() -> Void)?, onDisagree: (() -> Void)?) {
            self.disclaimer = disclaimer
            self.rules = rules
            self.onAgree = onAgree
            self.onDisagree = onDisagree
        }
        
        fileprivate static var empty: ViewModel {
            return .init(disclaimer: nil, rules: [], onAgree: nil, onDisagree: nil)
        }
    }
    
    @ObservedObject var viewModel: ViewModel = .empty

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let disclaimer = viewModel.disclaimer {
                    Text(disclaimer)
                        .padding(.bottom, 30)
                }

                ForEach(Array(viewModel.rules.enumerated()), id: \.offset) { index, rule in
                    ZStack(alignment: .topLeading) {
                        Text("\(index + 1)")
                            .font(.system(size: UIFontMetrics.default.scaledValue(for: 24), weight: .bold))
                            .foregroundStyle(Asset.Colors.Brand.blurple.swiftUIColor)
                        VStack(alignment: .leading, spacing: tinySpacing) {
                            Text(rule.possiblyTranslatedTitle)
                                .padding(.leading, 30)
                            if let detail = rule.possiblyTranslatedDetail {
                                Text(detail)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 30)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
                

            }
        }
        .padding(.horizontal)
        .safeAreaInset(edge: .bottom) {
            if viewModel.onDisagree != nil || viewModel.onAgree != nil {
                VStack {
                    if let onDisagree = viewModel.onDisagree {
                        Button(role: .cancel) {
                            onDisagree()
                        } label: {
                            Text(L10n.Scene.ServerRules.Button.disagree)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.clear)
                        .foregroundStyle(Asset.Colors.Brand.blurple.swiftUIColor)
                    }
                    
                    if let onAgree = viewModel.onAgree {
                        Button {
                            onAgree()
                        } label: {
                            Text(L10n.Scene.ServerRules.Button.confirm)
                                .frame(maxWidth: .infinity)
                                .bold()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .controlSize(.large)
                .padding()
                .background(.ultraThinMaterial)
                .tint(Asset.Colors.Brand.blurple.swiftUIColor)
            }
        }
    }
}

private struct MastodonServerRulesButton: View {
    let text: LocalizedStringKey
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
        }
        .font(Font(UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16, weight: .semibold))))
    }
}

final class MastodonServerRulesViewController: UIHostingController<MastodonServerRulesView> {
    
    init(viewModel: MastodonServerRulesView.ViewModel) {
        super.init(rootView: MastodonServerRulesView())
        self.rootView.viewModel = viewModel
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MastodonServerRulesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOnboardingAppearance()
        defer { setupNavigationBarBackgroundView() }

        navigationItem.largeTitleDisplayMode = .always
        title = L10n.Scene.ServerRules.title
    }
}

// MARK: - OnboardingViewControllerAppearance
extension MastodonServerRulesViewController: OnboardingViewControllerAppearance { }
