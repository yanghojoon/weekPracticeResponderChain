//
//  YellowButton.swift
//  weekPracticeResponderChain
//
//  Created by 양호준 on 2022/01/01.
//

import UIKit

class YellowButton: UIButton {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isUserInteractionEnabled || isHidden || alpha <= 0.01 {
            print("노랑버튼 - 아무것도 리턴되지 않음")
            return nil
        }
        
        if self.point(inside: point, with: event) { // 클릭당한 것
            for subview in subviews.reversed() {
                let convertedPoint = subview.convert(point, from: self) // superview가 subview의 포인트를 바꿔주고 있다. subview의 위치는 상대적(superview에서 얼마나 떨어져 있는지)이다. (상대적 좌표) 터치를 했을 때 상대적인 좌표를 찾을 수 없다. 직접적인 위치를 superview를 통해 찾는 과정이다.
                if let hitTestView = subview.hitTest(convertedPoint, with: event) {
                    print("노란 버튼의 hitTest: \(hitTestView)")
                    return hitTestView
                }
            }
            print("노란 버튼이 가장 위")
            return self
        }
        return nil
    }
}
