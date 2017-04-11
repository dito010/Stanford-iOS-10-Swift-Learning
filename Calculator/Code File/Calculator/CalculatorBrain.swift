//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by 尹久盼 on 2017/4/10.
//  Copyright © 2017年 NewPan. All rights reserved.
//

import Foundation

// 注意, 这里结构体, 这样类更加轻量级.
struct CalculatorBrain {
    
    // 私有变量, 因为可能没有被赋值, 所以可选.
    private var accumulator : Double?
    
    // 设置数值
    // 修改了结构体里的属性, 所以要使用 mutating 关键字修饰, 默认结构体的属性是不可修改的.
    mutating func setOperand(_ operand : Double) {
        accumulator = operand
    }
    
    // 取值, 结果是 read-only.
    var result : Double? {
        get{
            return accumulator
        }
    }
    
    // 先将操作进行分类, 编为枚举, 成为 "操作分类" 的组件.
    // swift新特性, 枚举中可以携带参数.
    private enum Operation{
        case clear // 清空显示器.
        case constant(Double) // 常量, 例如 π.
        case unaryOperation((Double) -> Double) // 一元运算, 传递接受一个变量并有一个返回值的函数.
        case binaryOperation((Double, Double) -> Double) // 二元运算, 传递接受两个参数并有一个返回值的函数.
        case equals // 取结果
    }
    
    // 根据操作分类将不同的操作和对应的运算以键值对的形式保存起来.
    // swift新特性, 字典中存枚举.
    private var operation : Dictionary<String, Operation> = [
        "C" : Operation.clear,
        "π" : Operation.constant(Double.pi), // 常量, 例如 π.
        "√" : Operation.unaryOperation(sqrt), // 一元运算, 这里只传方法给函数, 只要是参数为 (Double) -> Double 的方法都可以使用
//        "±" : Operation.unaryOperation({(op1 : Double) -> Double in // 使用闭包(closure)来精简代码
//            return -op1
//        }),
        "±" : Operation.unaryOperation({ -$0 }), // swift的参数默认以 $0, $1, $2.... 命名, 这里取到第一个参数, 并取相反数以后返回, 这是 swift的新特性.
//        "×" : Operation.binaryOperation({(op1 : Double, op2 : Double) -> Double in
//            return op1 * op2
//        })
        "×" : Operation.binaryOperation({ $0 * $1}),
        "÷" : Operation.binaryOperation({ $0 / $1}),
        "+" : Operation.binaryOperation(){$0 + $1},
        "-" : Operation.binaryOperation(){$0 - $1},
        "=" : Operation.equals
    ]
    
    // 定义一个结构体, 用来处理运算.
    private struct PendingBinaryOperation {
        let function : (Double, Double) -> Double
        let firstOperand : Double
        
        func perform(with secondOperand : Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    // 因为每次计算都会创建一个新的 PendingBinryOperation 实例来进行运算, 所以使用完成以后会被清空, 所以可能会为 nil, 所以是 ?(可选的)
    private var pendingBinaryOperation : PendingBinaryOperation?
    
    // 修改了结构体里的属性, 所以要使用 mutating 关键字修饰, 默认结构体的属性是不可修改的.
    mutating func perfromOperation(_ symbol : String){
        if let operation = operation[symbol] {
            switch operation {
            case .clear: // 清空显示器.
                accumulator = 0
            case .constant(let value) : // 取常量的值.
                accumulator = value
            case .unaryOperation(let function) : // 一元运算
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function ) : // 二元运算
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil // 使用完成以后需要置空, 因为下次使用时会重新赋值
                }
            case .equals :
                performPendingBinaryOpeartion()
            }
        }
    }
    
    private mutating func performPendingBinaryOpeartion() {
        if pendingBinaryOperation != nil && accumulator != nil { // 处理运算的结构体要有值, 并且要有两个参数.
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil // 使用完成以后需要置空, 因为下次使用时会重新赋值
        }
    }
}


