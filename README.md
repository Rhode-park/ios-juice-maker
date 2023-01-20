

# Juice Maker🧃

## 목차
1. [소개](#1-소개)
2. [팀원](#2-팀원)
3. [타임라인](#3-타임라인)
4. [프로젝트 구조](#4-프로젝트-구조)
5. [실행화면(기능 설명)](#5-실행-화면기능-설명)
6. [트러블슈팅](#6-트러블-슈팅)
7. [참고링크](#7-참고-링크)
8. [아쉬운점](#8-아쉬운-점)
9. [팀 회고](#9-팀-회고)

## 9. 팀 회고
## 1. 소개
가지고 있는 과일들을 사용하여 과일 쥬스를 만드는 어플리케이션입니다. 딸기, 바나나, 키위, 파인애플, 망고를 사용하여 딸기쥬스, 바나나쥬스, 키위쥬스, 파인애플 쥬스, 망고 쥬스, 망고 키위 쥬스를 제작할 수 있습니다.


<br/>

## 2. 팀원

|⭐️Rhode|⭐️Christy|
| :--------: | :--------: |
|<img height="180px" src="https://i.imgur.com/XyDwGwe.jpg">|<img height="180px" src="https://i.imgur.com/kHLXeMG.png">|



</br>

## 3. 타임라인
### 프로젝트 진행 기간
**23.01.02 (월) ~ 23.01.20 (금)** 

|날짜|타임라인|
| :-------: | :-------: |
|23.01.02 (월)|참고 공식 문서 학습|
|23.01.03 (화)|FruitStore, JuiceMaker, ErrorMessage 작성|
|23.01.04 (수)|1차 리팩토링, STEP1 1차 PR|
|23.01.05 (목)|2차 리팩토링, STEP1 2차 PR|
|23.01.06 (금)|3차 리팩토링, 공식 문서 학습, STEP1 머지|
|23.01.09 (월)|공식 문서 학습, STEP2 1차 PR|
|23.01.10 (화)|1차 리팩토링|
|23.01.11 (수)|STEP2 머지, 공식 문서 학습|
|23.01.12 (목)|StockModifyViewController 작성, 오토레이아웃 적용|
|23.01.13 (금)|STEP3 1차 PR|
|23.01.16 (월)|은닉화, viewController 이름 변경|
|23.01.17 (화)|delegate 적용 시작|
|23.01.18 (수)|delegate 리팩토링|
|23.01.19 (목)|delegate 리팩토링|
|23.01.20 (금)|STEP3 머지|

<br/>

## 4. 프로젝트 구조
### 클래스 다이어그램
![](https://i.imgur.com/ZtqiREb.jpg)


<br/>

## 5. 실행 화면(기능 설명)
![](https://i.imgur.com/NflsRzx.gif)

</br>

## 6. 트러블 슈팅
### 1. 동일한 코드가 반복되는 문제
`let recipe` 부터 throw `JuiceMakerError.invalidFruit`까지가 `isStocked`에서도 반복되는 문제가 있었습니다.
```swift
    func useFruit(juice: Recipe) throws {
        let recipe = Recipe.selectRecipe(recipe: juice)
        for (key, value) in recipe {
            guard let stock = fruitStock[key] else {
                throw JuiceMakerError.invalidFruit
            }
        ...
        }
    }
    
    func isStocked(juice: Recipe) -> Bool {
    ...
    }
```
해당 코드의 for문 부분을 isStocked로 남기고, isStocked에서 success와 failure로 구분해 재고를 반환하는 방법을 선택했습니다.
```swift
func isStocked(juice: Juice) -> Result<[(fruit: Fruit, stock: Int)], JuiceMakerError> {
        let juice = juice.selectRecipe
        var fruitList: [(Fruit, Int)] = []
        for (fruit, amount) in juice {
            guard let stock = fruitStock[fruit] else {
                return .failure(JuiceMakerError.invalidFruit)
            }
            let newStock = stock - amount
            fruitList.append((fruit, newStock))
            if newStock < 0 {
                return .failure(JuiceMakerError.outOfStock)
            }
        }
        return .success(fruitList)
    }
```
이런 방법을 통해서 재고가 있을 경우에는 재고에 대한 정보를 useFruit에서 받아와서 처리해주는 방향으로 해결하였습니다.

<br/>

### 2. 딕셔너리를 사용해 for문을 돌리는 방법
```swift
static func selectRecipe(recipe: Recipe) -> [FruitType:Int] {
        switch recipe {
        case .딸기쥬스:
            return [.딸기: 16]
        case .바나나쥬스:
            return [.바나나: 2]
        case .키위쥬스:
            return [.키위: 3]
        case .파인애플쥬스:
            return [.파인애플: 2]
        case .딸바쥬스:
            return [.딸기: 10, .바나나: 1]
        case .망고쥬스:
            return [.망고: 3]
        case .망고키위쥬스:
            return [.망고: 2, .키위: 1]
        }
    }
```
위와 같은 딕셔너리를 통해 레시피를 관리하고 있는데요. 초기에는 이를 사용할 방법을 잘 찾지 못했습니다. 코드를 짤 초기에는 
```swift
    case .딸기쥬스:
        return ["딸기": 16]
```
이와 같은 형태를 가지고 있었고, 각각의 케이스에 서브스크립트를 사용하여 접근하고자 했습니다. 그래서 그 과정에서 서브스크립트를 잘 사용하기 위해서 key값도 ```.딸기```와 같이 enum을 적용해서 바꾸어 주었습니다. 그렇지만, 서브크립트를 사용하려니 여러차례 옵셔널 바인딩을 해야했습니다. 그래서 다른 방법을 찾아보았고 [이 게시물](https://jellysong.tistory.com/91)을 보고 key와 value에 접근하여 for문을 돌리는 방법을 알게 되었습니다. 그리고 현재의 ```for (key, value) in recipe``` 코드로는 꼭 ```.딸기```와 같이 enum을 적용해서 써줄 필요는 없는 것 같습니다. 그렇지만, String을 사용하는 것보다 enum을 적용해서 작성해주는 것이 조금 더 간결해보이기 때문에 그렇게 유지하고 있습니다.

<br/>

### 3. 튜플 사용시 라벨이 사용 되지 않는 문제
```swift
for fruit in remainder {
    fruitStock[fruit.0] = fruit.1
}
```
쥬스를 제작하고 남은 재고를 `fruitstock[fruit.0] = fruit.1`에서 `fruit.0`과 `fruit.1`대신 `fruit.name`등으로 받아오고 싶었습니다.

```swift
func isStocked(juice: Juice) -> Result<[(Fruit, Int)], JuiceMakerError> {
        let juice = juice.selectRecipe
        var fruitList: [(fruit: Fruit, stock: Int)] = []
        for (fruit, amount) in juice {
            guard let stock = fruitStock[fruit] else {
                return .failure(JuiceMakerError.invalidFruit)
            }
            let newStock = stock - amount
            fruitList.append((fruit: fruit, stock: newStock))
            if newStock < 0 {
                return .failure(JuiceMakerError.outOfStock)
            }
        }
        return .success(fruitList)
    }
```
그래서 위와 같이 코드를 고쳤는데 전혀 반영이 되지 않았습니다. 그러다가 중요한 것은 반환타입이라는 것을 깨달았습니다.
```swift
func isStocked(juice: Juice) -> Result<[(fruit: Fruit, stock: Int)], JuiceMakerError> {
        ...
    }
```
이렇게 Result안의 배열 안의 튜플에 라벨을 달아줘야합니다.

```swift
for fruit in remainder {
    fruitStock[fruit.fruit] = fruit.stock
}
```
그 결과 이렇게 fruit과 stock이라는 라벨을 사용해서 값에 접근할 수 있게 되었습니다.

<br/>

### 4. 네비게이션은 넘어가지만, 두 번째 뷰의 요소들을 사용할 수 없는 상황
쥬스를 만드는 화면은 ViewController에 그리고 재고 관리 화면은 StockModifyViewController에 연결이 되어있습니다. 초기에는 네비게이션 바의 backButton 문구를 수정하고자 StockModifyViewController 파일에 변경하고자 하는 내용을 작성했습니다. 하지만 backButton title의 경우 ViewController 화면에서 수정 코드를 작성해야 함을 알았습니다.
이후 StockModifyViewController와 해당하는 화면이 연결되었나 확인하려고 StockModifyViewController에 print문을 작성해보니 콘솔창에 아무것도 나오지 않았습니다. 그리고 'Inherit Module From Target'부분이 체크가 되어있지 않다는 것을 깨달았습니다.
![](https://i.imgur.com/tUoJjDW.png)
그래서 현재는 위와 같이 체크를 해 놓은 상태이고 정상적으로 두 번째 뷰의 요소들을 사용할 수 있습니다.

<br/>

### 5. 모달로 바꾸었지만 요소들에 nil이 들어가 런타임 오류가 생기는 경우

처음에는 다음과 같은 방식으로 모달을 구현했습니다.
```swift
let stockModifyViewController = StockModifyViewController()
stockModifyViewController.modalPresentationStyle = stockModifyViewController.fullScreen
self.present(stockModifyViewController, animated: true, completion: nil)
```
그런데, 두 번째 뷰컨트롤러의 Label들에 nil이 들어가 암시적 추출한 라벨들이 먹히지 않는 일이 생겼습니다.
고민을 해보니 스토리 보드를 불러오는 것이 아닌 뷰 컨트롤러를 불러와서 이런 문제가 생긴 것 같습니다.
```swift
guard let stockModifyViewController = self.storyboard?.instantiateViewController(withIdentifier: "stockModifyViewController") else {
            return
        }
````
그래서 이렇게 스토리보드를 사용한 코드를 넣어주었습니다.
덧붙여서 원래 있던 네비게이션 컨트롤러를 사용하기 위해서 다음과 같이 코드를 수정했습니다.

```swift
func presentModal() {
        guard let stockModifyViewController = self.storyboard?.instantiateViewController(withIdentifier: "stockModifyViewController") else {
            return
        }
        let navigationController = UINavigationController(rootViewController: stockModifyViewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(navigationController, animated: true, completion: nil)
    }
```

<br/>

### 6. Stepper 사이즈 조정이 안되는 경우 

```swift
stepper.transform = stepper.transform.scaledBy(x: 1.25, y: 0.9)
```

재고 관리 뷰에서 객체들을 stack view에 넣고 크기를 조정하던 중 UIStepper의 사이즈 변경이 안되는 문제를 발견했습니다. 다양한 문서를 찾아보니 UIStepper의 사이즈 수정은 스토리보드가 아닌 viewController에서 코드로 작성해 줘야 함을 알게 되었습니다.


<br/>

## 7. 참고 링크
> - [Swift 공식문서 - Error Handling](https://docs.swift.org/swift-book/LanguageGuide/ErrorHandling.html)
> - [Swift 공식문서 - Enumeration](https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html)
> - [Swift 공식문서 - Structures and Classes](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html)
> - [Swift 공식문서 - UIViewController](https://developer.apple.com/documentation/uikit/uiviewcontroller)
> - [Swift 공식문서 - UIStepper](https://developer.apple.com/documentation/uikit/uistepper)
> - [[Swift] Collection Type - 딕셔너리(Dictionary), 반복문, key/value 기반 정렬](https://jellysong.tistory.com/91)

<br/>

## 8. 아쉬운 점
### STEP 1
* nil을 통해 무언가가 되지 않는 경우에 대한 정보를 전달하고 있다는 점이 아쉬웠습니다: 근본적으로 nil반환이 나쁜 것은 아니지만, 사용자가 경고해야할 일이 있는 경우 error를 반환하는게 좋다고 합니다. 그래서 추후에 step02, 03을 진행하면서 리팩토링 할 생각입니다.

### STEP 2
* 해당 step에서 은닉화를 적용하지 못 한 부분이 아쉬웠습니다: 적절하게 은닉화를 사용하는 방법에 대해 고민하여 step3를 진행하며 리팩토링 했습니다. 

### STEP 3
* delegate 적용

<br/>

---


## 9. 팀 회고
### 우리팀이 잘한 점
- 서로 의견을 존중하며 상대방을 배려함
- 다양한 방법을 시도해보고자 함

### 우리팀 개선할 점
- 적절한 휴식을 취해야 함
- 고민이 생겼을 때 둘이서 고민하다가도 답이 나오지 않으면 주변의 도움을 적극적으로 받는 태도를 가져야할 것 같음


### 팀원 서로 칭찬하기 부분
Christy -> Rhode : 학습에 있어 항상 열정이 넘치고 긍정적입니다. 어려운 문제를 만나 앞길이 막막해 보일 때 혜성처럼 나타나 해답을 제시해 주셨습니다. 의문이 드는 부분에 대해 포기하지 않고 이해할 때 까지 학습을 멈추지 않으십니다. 그러한 모습을 보며 긍정적인 영향을 받아 더 열심히 학습할 수 있었습니다.

Rhode -> Christy: 크리스티는 상대방을 존중할 줄 아는 캠퍼입니다. 어떠한 의견을 개진해도 잘 수용해줍니다. 새로운 개념을 접했을 때 그것을 완벽히 이해하려고 노력하는 모습을 보입니다. 크리스티의 가장 큰 강점은 수용능력과 끈기입니다!

