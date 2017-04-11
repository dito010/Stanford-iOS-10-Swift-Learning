//
//  ViewController.swift
//  Calculator
//
//  Created by lava on 2017/4/10.
//  Copyright © 2017年 NewPan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // 用户是否正在输入
    var userIsInTheMiddleOfTyping = false
    
    // 控制器拥有Model是私有的
    private var brain = CalculatorBrain()

    @IBOutlet weak var display: UILabel!
    
    // 计算属性
    var displayValue : Double {
        // 负责将用户输入的数字显示到屏幕上, 同时可以将屏幕上的文字以 double 的形式取出
        set{
            display.text = String(newValue)
        }
        get{
            return Double(display.text!)! // 第一个强制解包是取显示器上的文字, 第二个强制解包是将转换的字符串取出
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let curDisplay = display.text!
        
        if userIsInTheMiddleOfTyping {
            display.text = curDisplay + digit
        }
        else{
            userIsInTheMiddleOfTyping = true
            display.text = digit
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        // 记录要运算的值
        if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
            brain.setOperand(displayValue)
        }
        
        // 传进运算符进行计算
        if let symbol = sender.currentTitle {
            brain.perfromOperation(symbol)
        }
        
        // 显示结果
        if let result = brain.result {
            displayValue = result
        }
    }
    
}

