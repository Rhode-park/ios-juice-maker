//
//  JuiceMaker - FruitStore.swift
//  Created by Rhode, Christy. 
//  Copyright © yagom academy. All rights reserved.
//

import Foundation

// 과일 저장소 타입
class FruitStore {
    var fruitStock:[Fruit: Int] = [.딸기: 10, .바나나: 10, .파인애플: 10, .키위: 10, .망고: 10]
    
    func useFruit(juice: Juice) throws {
        let juice = Juice.selectRecipe(recipe: juice)
        for (fruit, amount) in juice {
            guard let stock = fruitStock[fruit] else {
                throw JuiceMakerError.invalidFruit
            }
            let newStock = stock - amount
            fruitStock[fruit] = newStock
        }
    }
    
    func isStocked(juice: Juice) -> Bool {
        let juice = Juice.selectRecipe(recipe: juice)
        for (fruit, amount) in juice {
            guard let stock = fruitStock[fruit] else {
                return false
            }
            if stock < amount {
                return false
            }
        }
        return true
    }
}

