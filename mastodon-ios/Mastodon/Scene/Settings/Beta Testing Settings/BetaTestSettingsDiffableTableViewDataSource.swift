// Copyright © 2025 Mastodon gGmbH. All rights reserved.

import UIKit

class BetaTestSettingsDiffableTableViewDataSource: UITableViewDiffableDataSource<BetaTestSettingsSectionType, BetaTestSetting> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let settingsSectionType = sectionIdentifier(for: section) else { return nil }
        
        return settingsSectionType.sectionTitle.uppercased()
    }
}
