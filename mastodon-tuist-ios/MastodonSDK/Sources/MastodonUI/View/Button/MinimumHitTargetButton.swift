//
//  HitTestExpandedButton.swift
//  Mastodon
//
//  Created by sxiaojian on 2021/2/1.
//

import UIKit

public final class MinimumHitTargetButton: UIButton {
    
    public var minimumTappableSize: CGSize = CGSize(width: 44, height: 44)
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let sizeDiff = CGSize(width: minimumTappableSize.width - bounds.width, height: minimumTappableSize.height - bounds.height)
        let expandedBounds = bounds.insetBy(dx: min(0, -(sizeDiff.width / 2)), dy: min(0, -(sizeDiff.height / 2)))
        return expandedBounds.contains(point)
    }
    
}
