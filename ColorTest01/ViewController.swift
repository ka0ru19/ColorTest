//
//  ViewController.swift
//  ColorTest01
//
//  Created by 井上航 on 2016/05/09.
//  Copyright © 2016年 Wataru Inoue. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController {
    
    var screenHeight: CGFloat! // 縦
    var screenWidth: CGFloat! // 横
    
    var edge: CGFloat = 20 // 端
    var interval: CGFloat = 5 // 間隔
    var buttonHeight: CGFloat = 50 // ボタンの高さ
    
    var nextY: CGFloat = 0 // 最後に配置した部品の絶対ｙ座標
    var buttonsStartY: CGFloat = 0
    
    var firstButton: UIButton!
    
    var resetButton: UIButton!
    
    var scoreLabel: UILabel!
    var timerLabel: UILabel!
    
    var buttonArray: [UIButton!] = []
    var answerArray: [Int] = []
    
    var difNum: Int!
    
    var givePoint: Int = 100
    
    var changeColorLevel: CGFloat = 30
    
    var score: Int = 0
    
    var timer: NSTimer!
    let timeLimit: Float = 30.0
    var cnt: Float = 30.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Viewの背景色を青にする.
        view.backgroundColor = UIColor.cyanColor()
        
        // iAd(バナー)の自動表示
        self.canDisplayBannerAds = true
        
        screenHeight = view.bounds.height
        screenWidth = view.bounds.width
        
        if screenHeight == 480 {
            print("4s")
            edge = 20
            interval = 3
            buttonHeight = 40
        }
        
        // Labelを作成. サイズの決定
        let myHeaderLabel: UILabel = UILabel(frame: CGRectMake(edge ,nextY + edge + interval, screenWidth - 2 * edge,buttonHeight))
        nextY +=  edge + buttonHeight + interval + interval
        // 背景をオレンジ色にする.
        myHeaderLabel.backgroundColor = UIColor.blueColor()
        // 枠を丸くする.
        myHeaderLabel.layer.masksToBounds = true
        // コーナーの半径.
        myHeaderLabel.layer.cornerRadius = 15.0
        // Labelに文字を代入.
        myHeaderLabel.text = "Let's TAP Different Color!!"
        // 文字の色を白にする.
        myHeaderLabel.textColor = UIColor.whiteColor()
        // 文字の影の色をグレーにする.
        myHeaderLabel.shadowColor = UIColor.grayColor()
        // Textを中央寄せにする.
        myHeaderLabel.textAlignment = NSTextAlignment.Center
        // Viewの背景色を青にする.
        self.view.backgroundColor = UIColor.cyanColor()
        // ViewにLabelを追加.
        self.view.addSubview(myHeaderLabel)
        
        
        // Labelを作成. サイズの決定
        scoreLabel = UILabel(frame: CGRectMake(edge, nextY ,screenWidth - 2 * edge,buttonHeight))
        nextY += buttonHeight + interval
        // 背景をオレンジ色にする.
        scoreLabel.backgroundColor = UIColor.orangeColor()
        // 枠を丸くする.
        scoreLabel.layer.masksToBounds = true
        // コーナーの半径.
        scoreLabel.layer.cornerRadius = 15.0
        // Labelに文字を代入.
        scoreLabel.text = "GET HIGH SCORE!!"
        // 文字の色を白にする.
        scoreLabel.textColor = UIColor.whiteColor()
        // 文字の影の色をグレーにする.
        scoreLabel.shadowColor = UIColor.grayColor()
        // Textを中央寄せにする.
        scoreLabel.textAlignment = NSTextAlignment.Center
        // Viewの背景色を青にする.
        self.view.backgroundColor = UIColor.cyanColor()
        // ViewにLabelを追加.
        self.view.addSubview(scoreLabel)
        
        
        // Labelを作成. サイズの決定
        timerLabel = UILabel(frame: CGRectMake(edge, nextY ,screenWidth - 2 * edge,buttonHeight/2))
        nextY += buttonHeight / 2 + interval
        // 背景をオレンジ色にする.
        timerLabel.backgroundColor = UIColor.clearColor()
        // Labelに文字を代入.
        timerLabel.text = "in 30 second"
        // 文字の色を黒にする.
        timerLabel.textColor = UIColor.blackColor()
        // Textを中央寄せにする.
        timerLabel.textAlignment = NSTextAlignment.Center
        // ViewにLabelを追加.
        self.view.addSubview(timerLabel)
        
        buttonsStartY = nextY
        
        displayFirstButton()
        
        // Buttonを生成する.
        resetButton = UIButton()
        // サイズを設定する.
        resetButton.frame = CGRectMake(edge,nextY,(screenWidth-interval)/2-edge, buttonHeight - 10)
        // 背景色を設定する.
        resetButton.backgroundColor = UIColor.redColor()
        // 枠を丸くする.
        resetButton.layer.masksToBounds = true
        // タイトルを設定する(通常時).
        resetButton.setTitle("reset", forState: UIControlState.Normal)
        resetButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        // コーナーの半径を設定する.
        resetButton.layer.cornerRadius = 15.0
        // イベントを追加する.
        resetButton.addTarget(self, action: "onClickResetButton", forControlEvents: .TouchUpInside)
        
        // ボタンをViewに追加する.
        self.view.addSubview(resetButton)
        
        
        
    }
    
    //    func startTimer() {
    //        if let timer = timer {
    //            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    //        }
    //    }
    
    func onClickResetButton() {
        
        timer.invalidate()
        
        displayFirstButton()
        
        
    }
    
    // NSTimerIntervalで指定された秒数毎に呼び出されるメソッド.
    func onUpdate(timer : NSTimer){
        
        cnt = cnt - 0.01
        
        //桁数を指定して文字列を作る.
        let str = "Time:".stringByAppendingFormat("%.2f",cnt)
        
        timerLabel.text = str
        
        if cnt < 0.0 {
            timeOut()
            //            displayFirstButton()
        }
        
    }
    
    func timeOut() {
        timer.invalidate()
        timerLabel.text = "time up"
        var index0: Int = 0
        for i in 0 ..< answerArray.count {
            if answerArray[i] == 0 {
                index0 = index0 + 1
            }
        }
        print("all:\(answerArray.count), correct:\(index0)")
        let labelStr = "YourScore:" + String(score) + "p, Correct:".stringByAppendingFormat("%.1f",Float(index0)/Float(answerArray.count)*100) + "%"
        scoreLabel.text = labelStr
        print(labelStr)
        
        let count = self.buttonArray.count
        for i in 0 ..< count {
            buttonArray[i].enabled = true
            buttonArray[i].removeTarget(self, action:"onClickMyButton:", forControlEvents: .TouchUpInside)
            buttonArray[i].addTarget(self, action: "displayFirstButton", forControlEvents: .TouchUpInside)
        }
        
    }
    
    // "START!画面"
    func displayFirstButton() {
        let numOfRow: Int = 6
        let numOfColumn: Int = 5
        let length: CGFloat = (screenWidth - edge * 2 - (CGFloat(numOfRow) - 1 ) * interval ) / CGFloat(numOfRow)
        
        let buttonNextY = buttonsStartY
        
        score = 0
        cnt = timeLimit
        
        // button, answer 初期化
        let count = self.buttonArray.count
        for i in 0 ..< count {
            self.buttonArray[i].removeFromSuperview()
        }
        buttonArray = []
        answerArray = []
        
        for y in 0 ..< numOfColumn {
            for x in 0 ..< numOfRow {
                
                let r: CGFloat = CGFloat(arc4random_uniform(UInt32(256)))
                let g: CGFloat = CGFloat(arc4random_uniform(UInt32(256)))
                let b: CGFloat = CGFloat(arc4random_uniform(UInt32(256)))
                
                // Buttonを生成する.
                firstButton = UIButton()
                
                // サイズを設定する.
                let startX: CGFloat = edge + CGFloat(x) * (length + interval)
                let startY: CGFloat = buttonNextY + CGFloat(y) * (length + interval)
                firstButton.frame = CGRectMake(startX, startY,length,length)
                
                if x == 0 && y == 4 {
                    nextY = startY + length + edge
                }
                
                // 背景色を設定する.
                firstButton.backgroundColor = UIColor(red: r/256, green: g/256, blue: b/256, alpha: 1.0) //UIColor.redColor()
                
                // 枠を丸くする.
                firstButton.layer.masksToBounds = true
                
                // タイトルを設定する(通常時).
                firstButton.setTitle("", forState: UIControlState.Normal)
                firstButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                
                // タイトルを設定する(ボタンがハイライトされた時).
                //                myButton.setTitle("!!!", forState: UIControlState.Highlighted)
                //                myButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
                
                // コーナーの半径を設定する.
                firstButton.layer.cornerRadius = 20.0
                
                // ボタンの位置を指定する.
                //        myButton.layer.position = CGPoint(x: self.view.frame.width/2, y:200)
                
                // タグを設定する.
                let tagNum = x + (y * numOfRow) + 1
                firstButton.tag = tagNum
                
                // イベントを追加する.
                firstButton.addTarget(self, action: "onClickFirstButton", forControlEvents: .TouchUpInside)
                
                buttonArray.append(firstButton)
                
                // ボタンをViewに追加する.
                self.view.addSubview(firstButton)
                
            }
        }
        
        buttonArray[12].setTitle("S", forState: .Normal)
        buttonArray[13].setTitle("T", forState: .Normal)
        buttonArray[14].setTitle("A", forState: .Normal)
        buttonArray[15].setTitle("R", forState: .Normal)
        buttonArray[16].setTitle("T", forState: .Normal)
        buttonArray[17].setTitle("!", forState: .Normal)
        timerLabel.text = "in 30 second"
        scoreLabel.text = "GET HIGH SCORE"
        
        timer = NSTimer(timeInterval: 0.01, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
        
        
    }
    
    func displayButton(numOfRow: Int, _ numOfColumn: Int) {
        
        // button 初期化
        let count = self.buttonArray.count
        for i in 0 ..< count {
            self.buttonArray[i].removeFromSuperview()
        }
        self.buttonArray = []
        
        let length: CGFloat = (screenWidth - edge * 2 - (CGFloat(numOfRow) - 1 ) * interval ) / CGFloat(numOfRow)
        
        let buttonNextY = buttonsStartY
        
        let r: CGFloat = CGFloat(arc4random_uniform(UInt32(256)))
        let g: CGFloat = CGFloat(arc4random_uniform(UInt32(256)))
        let b: CGFloat = CGFloat(arc4random_uniform(UInt32(256)))
        difNum = Int(arc4random_uniform(UInt32(numOfRow*numOfColumn))) + 1
        print("r:\(r),g:\(g),b:\(b)")
        print("difNum\(difNum)")
        
        for y in 0 ..< numOfColumn {
            for x in 0 ..< numOfRow {
                // Buttonを生成する.
                firstButton = UIButton()
                // サイズを設定する.
                let startX: CGFloat = edge + CGFloat(x) * (length + interval)
                let startY: CGFloat = buttonNextY + CGFloat(y) * (length + interval)
                firstButton.frame = CGRectMake(startX, startY,length,length)
                // 枠を丸くする.
                firstButton.layer.masksToBounds = true
                // 枠を透明にする
                firstButton.layer.borderColor = UIColor.clearColor().CGColor
                // タイトルを設定する(通常時).
                firstButton.setTitle("", forState: UIControlState.Normal)
                firstButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                // コーナーの半径を設定する.
                firstButton.layer.cornerRadius = 20.0
                
                // タグを設定する.
                let tagNum = x + (y * numOfRow) + 1
                firstButton.tag = tagNum
                
                // 一つだけ色を変える
                if tagNum == difNum {
                    var rgbArray: [CGFloat!] = [r,g,b]
                    let difRoot: Int = Int(arc4random_uniform(UInt32(6))) // 0~5
                    
                    if difRoot == 0 {
                        if rgbArray[0] < 255 - changeColorLevel {
                            rgbArray[0] = r + changeColorLevel
                        } else {
                            rgbArray[0] = r - changeColorLevel
                        }
                        
                    }  else if difRoot == 1 {
                        if rgbArray[0] > changeColorLevel {
                            rgbArray[0] = r - changeColorLevel
                        } else {
                            rgbArray[0] = r + changeColorLevel
                        }
                        
                    } else if difRoot == 2 {
                        if rgbArray[1] < 255 - changeColorLevel {
                            rgbArray[1] = g + changeColorLevel
                        } else {
                            rgbArray[1] = g - changeColorLevel
                        }
                        
                    } else if difRoot == 3 {
                        if rgbArray[1] > changeColorLevel {
                            rgbArray[1] = g + changeColorLevel
                        } else {
                            rgbArray[1] = g - changeColorLevel
                        }
                        
                    } else if difRoot == 4 {
                        
                        if rgbArray[2] < 255 - changeColorLevel {
                            rgbArray[2] = b + changeColorLevel
                        } else {
                            rgbArray[2] = b - changeColorLevel
                        }
                    } else if difRoot == 5 {
                        
                        if rgbArray[2] > changeColorLevel {
                            rgbArray[2] = b - changeColorLevel
                        } else {
                            rgbArray[2] = b + changeColorLevel
                        }
                    }
                    
                    firstButton.backgroundColor = UIColor(red: rgbArray[0]/256, green: rgbArray[1]/256, blue: rgbArray[2]/256, alpha: 1.0)
                } else {
                    firstButton.backgroundColor = UIColor(red: r/256, green: g/256, blue: b/256, alpha: 1.0)
                }
                
                // イベントを追加する.
                firstButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
                
                buttonArray.append(firstButton)
                
                // ボタンをViewに追加する.
                self.view.addSubview(firstButton)
                
            }
        }
        
    }
    
    /*
     ボタンのアクション時に設定したメソッド.
     */
    func onClickFirstButton() {
        
        scoreLabel.text = "Ready??"
        
        // 遅延
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            self.scoreLabel.text = "Start!!"
            
            self.displayButton(6, 5)
            
            if let timer = self.timer {
                NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
            }

        }
        
    }
    
    func onClickMyButton(sender: UIButton){
        if sender.tag == difNum {
            if answerArray.last == 0 {
                givePoint = Int(Float(givePoint) * 1.5)
            } else {
                givePoint = 100
            }
            score += givePoint
            answerArray.append(0)
            scoreLabel.text = ("Correct👌")
        } else {
            givePoint = 100
            score -= givePoint / 5
            answerArray.append(1)
            scoreLabel.text = ("incorrect👋")
            
        }
        
        // タップ不能にする
        for btn in buttonArray {
            btn.enabled = false
        }
        
        // 正解のボタンに枠をつける
        buttonArray[difNum-1].layer.borderColor = UIColor.blackColor().CGColor
        buttonArray[difNum-1].layer.borderWidth = 3.0
        
        if cnt > 0.3 {
            
            // 遅延
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                self.displayButton(6, 5)
                
                self.scoreLabel.text = "Now Score: \(self.score)p!!"
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

