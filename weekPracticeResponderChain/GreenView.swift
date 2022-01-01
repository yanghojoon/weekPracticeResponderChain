//
//  GreenView.swift
//  weekPracticeResponderChain
//
//  Created by 양호준 on 2022/01/01.
//

import UIKit

class GreenView: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("그린 터치")
    }
    
    @objc func changeViewColor() {
        print("df")
        if self.backgroundColor != .black {
            print(1)
            self.backgroundColor = .black
        } else {
            self.backgroundColor = .systemGreen
            print(2)
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isUserInteractionEnabled || isHidden || alpha <= 0.01 {
            print("초록 뷰 - 아무것도 리턴되지 않음")
            return nil
        }

        if self.point(inside: point, with: event) { // 안에 터치가 됐니?
            for subview in subviews.reversed() { // 오렌지, 보라
                let convertedPoint = subview.convert(point, from: self)
                if let hitTestView = subview.hitTest(convertedPoint, with: event) {
                    print("그린 뷰의 hitTest: \(hitTestView)")
                    return hitTestView
                }
            }
            self.backgroundColor = .black
            print("그린 뷰가 제일 위")
            return self
        }
        return nil
    }
}
