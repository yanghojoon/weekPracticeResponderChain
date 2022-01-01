//
//  BlueView.swift
//  weekPracticeResponderChain
//
//  Created by 양호준 on 2022/01/01.
//

import UIKit

class BlueView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isUserInteractionEnabled || isHidden || alpha <= 0.01 {
            print("파랑 뷰 - 아무것도 리턴되지 않음")
            return nil
        }

        if self.point(inside: point, with: event) {
            for subview in subviews.reversed() {
                let convertedPoint = subview.convert(point, from: self)
                if let hitTestView = subview.hitTest(convertedPoint, with: event) {
                    print("파랑 뷰의 hitTest: \(hitTestView)")
                    return hitTestView
                }
            }
            print("파랑 뷰가 가장 위")
            return self
        }
        return nil
    }
}
