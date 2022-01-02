# hitTest

일단 hitTest가 뭔지 살펴보자. 
>Returns the farthest descendant of the receiver in the view hierarchy (including itself) that contains a specified point.

특정 위치에 터치가 되었을 때 view hierarchy에서 자신을 포함해 가장 먼 view를 반환하게 된다. 
(UIWindow부터 올라가면서 어떤 뷰가 눌렸는지 찾아가는 과정 

<img width="568" alt="스크린샷 2022-01-02 오전 9 21 14" src="https://user-images.githubusercontent.com/90880660/147863016-0600c366-eb90-4656-94e1-7e17757f510c.png">


```swift
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
        print("그린 뷰가 제일 위")
        return self
    }
    return nil
}
```

#### 1. 왜 `!isUserInteractionEnabled || isHidden || alpha <= 0.01` 이 때 `return nil`을 해주는 것일까
[hitTest 공식문서](https://developer.apple.com/documentation/uikit/uiview/1622469-hittest)에서 보면 아래와 같은 말이 있다. 

>This method ignores view objects that are hidden, that have disabled user interactions, or have an alpha level less than 0.01.

즉 hitMethod는 view가 1. isHidden일 때, 2. user interaction을 할 수 없을 때, 3. alpha가 0.01보다 작을 때 무시를 한다고 나와있다. 
여기서 alpha는 0.0에서 1.0의 값으로 0.0일 때는 완전히 투명해지며 1.0일 때는 반투명해진다. 즉, 거의 투명할 때 hitTest가 view를 무시한다고 볼 수 있다. 


#### 2. `if self.point(inside: point, with: event)`
이는 touch가 자신의 view 안에 터치가 되었는지 확인하는 조건이다. 

#### 3. `for subview in subviews.reversed()`을 왜 해주는 것일까?
우선 결론부터 말하면 가장 위에 있는 subview를 반환하기 위함이다. 

만약 뷰가 다음과 같은 순서로 쌓여있다고 생각해보자. 

초록뷰 -> 오렌지뷰 -> 보라뷰 

그렇다면 초록뷰의 subviews는 [오렌지뷰, 보라뷰]이런 식으로 구성이 될 것이다. 여기서 우리가 원하는 뷰는 가장 멀리 떨어진, 가장 위에 있는 뷰를 원하고 있다. 
따라서 이를 뒤집어서 해당 뷰가 터치됐다면 이를 반환해주는 것이다. 

#### 4. `let convertedPoint = subview.convert(point, from: self)` 
point를 convert해주는 이유는 subview의 위치가 상대적이기 때문에 이를 superview를 통해 위치를 찾아주는 과정이다. 
이는 frame과 bound에 대해 좀 더 공부하면 확실히 알 수 있을 것 같다. 

일단 흐름을 살펴보자면 `if let hitTestView = subview.hitTest(convertedPoint, with: event)`는 event가 있었던 곳에서 subview가 있었는지 확인을 하는 것이다.
만약 subview가 없었다면 자신이 가장 위에 있는 view인 것이고 자기 자신을 반환하게 되는 것이다. 

<br>

# Responder Chain
눌렸던 곳부터 UIAppDelegate까지 해당 event를 처리할 곳을 정하게 된다. 
hitTest와는 반대로 가장 위에서 부터 아래로 작동을 하게 된다. 

그렇다면 위 그림에서도 오렌지뷰를 눌러도 그린 뷰의 색을 변하게 하려면 그린 뷰에서 gesture recognizer를 가지고 있으면 된다. 
오렌지 뷰에는 처리할 방법이 따로 없다면 superview인 greenview로 responder chain이 이동하기 때문이다. 

```swift
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
            print("그린 뷰가 제일 위")
            return self
        }
        return nil
    }
}
```

greenView의 색을 변하게 해야 하기 때문에 changeViewColor라는 메서드를 만들어줬다. 
selector를 통해 실행이 될 수 있도록 해야하기 때문에 `@objc`를 붙여줬다. 

여기서 backgroundColor가 sytemGreen인지 비교하지 못하는 문제가 있었다... (아직 이 부분은 원인을 찾지 못했다)

그럼 ViewController로 이동해보자.

```swift
class ViewController: UIViewController {
    @IBOutlet weak var greenView: GreenView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let greenViewGestureRecognizer = UITapGestureRecognizer.init(target: greenView, action: #selector(greenView.changeViewColor))
        view.addGestureRecognizer(greenViewGestureRecognizer)
    }
}
```

일단 스토리보드에 있는 GreenView를 연결해주었다. 
그리고 greenView에 `gesture recognizer`를 연결해줬다. 

[UIGestureRecognizer의 init](https://developer.apple.com/documentation/uikit/uigesturerecognizer/1624211-init)

- target: 제스쳐가 인식되었을 대 이를 처리하고 action message를 받을 객체를 의미한다. (nil은 올 수 없다)
>An object that is the recipient of action messages sent by the receiver when it recognizes a gesture. nil is not a valid value.

- action: 제스쳐를 받은 reciever가 처리할 메서드를 작성하게 된다. 즉, target이 제스쳐를 인식했을 때 어떤 행동을 할지 정하는 것이다. 
>A selector that identifies the method implemented by the target to handle the gesture recognized by the receiver. 
The action selector must conform to the signature described in the class overview. NULL is not a valid value.
