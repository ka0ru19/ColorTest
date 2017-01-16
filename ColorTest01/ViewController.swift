//
//  ViewController.swift
//  ColorTest01
//
//  Created by 井上航 on 2016/05/09.
//  Copyright © 2016年 Wataru Inoue. All rights reserved.
//

import UIKit
import Social
import FirebaseDatabase
import GoogleMobileAds

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    var shareButton: UIButton!
    
    var scoreLabel: UILabel!
    var timerLabel: UILabel!
    
    var buttonArray: [UIButton?] = []
    var answerArray: [Int] = []
    
    var difNum: Int!
    
    var givePoint: Int = 100
    
    var changeColorLevel: CGFloat = 30
    
    var score: Int = 0
    
    var timer: Timer!
    let timeLimit: Float = 30.0
    var cnt: Float = 30.0
    
//    let itunesURL: String = "itms-apps://itunes.apple.com/app/XXXXXXXXX" // todo アプリIDを編集
    let itunesUrl: NSURL = NSURL(string: "itms-apps://itunes.apple.com/app/XXXXXXXXXX")!
    
    var ref : FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Viewの背景色を青にする.
        view.backgroundColor = UIColor.cyan
        
        // iAd(バナー)の自動表示
//        self.canDisplayBannerAds = true
        
        // Firebase
        ref = FIRDatabase.database().reference().child("list").child("score")
        
        screenHeight = view.bounds.height
        screenWidth = view.bounds.width
        
        if screenHeight == 480 {
            print("4s")
            edge = 20
            interval = 3
            buttonHeight = 40
        }
        
        // Labelを作成. サイズの決定
        let myHeaderLabel: UILabel = UILabel(frame: CGRect(x: edge ,y: nextY + edge + interval, width: screenWidth - 2 * edge,height: buttonHeight))
        nextY +=  edge + buttonHeight + interval + interval
        // 背景をオレンジ色にする.
        myHeaderLabel.backgroundColor = UIColor.blue
        // 枠を丸くする.
        myHeaderLabel.layer.masksToBounds = true
        // コーナーの半径.
        myHeaderLabel.layer.cornerRadius = 15.0
        // Labelに文字を代入.
        myHeaderLabel.text = "Let's TAP Different Color!!"
        // 文字の色を白にする.
        myHeaderLabel.textColor = UIColor.white
        // 文字の影の色をグレーにする.
        myHeaderLabel.shadowColor = UIColor.gray
        // Textを中央寄せにする.
        myHeaderLabel.textAlignment = NSTextAlignment.center
        // Viewの背景色を青にする.
        self.view.backgroundColor = UIColor.cyan
        // ViewにLabelを追加.
        self.view.addSubview(myHeaderLabel)
        
        
        // Labelを作成. サイズの決定
        scoreLabel = UILabel(frame: CGRect(x: edge, y: nextY ,width: screenWidth - 2 * edge,height: buttonHeight))
        nextY += buttonHeight + interval
        // 背景をオレンジ色にする.
        scoreLabel.backgroundColor = UIColor.orange
        // 枠を丸くする.
        scoreLabel.layer.masksToBounds = true
        // コーナーの半径.
        scoreLabel.layer.cornerRadius = 15.0
        // Labelに文字を代入.
        scoreLabel.text = "GET HIGH SCORE!!"
        // 文字の色を白にする.
        scoreLabel.textColor = UIColor.white
        // 文字の影の色をグレーにする.
        scoreLabel.shadowColor = UIColor.gray
        // Textを中央寄せにする.
        scoreLabel.textAlignment = NSTextAlignment.center
        // Viewの背景色を青にする.
        self.view.backgroundColor = UIColor.cyan
        // ViewにLabelを追加.
        self.view.addSubview(scoreLabel)
        
        
        // Labelを作成. サイズの決定
        timerLabel = UILabel(frame: CGRect(x: edge, y: nextY ,width: screenWidth - 2 * edge,height: buttonHeight/2))
        nextY += buttonHeight / 2 + interval
        // 背景をオレンジ色にする.
        timerLabel.backgroundColor = UIColor.clear
        // Labelに文字を代入.
        timerLabel.text = "in 30 second"
        // 文字の色を黒にする.
        timerLabel.textColor = UIColor.black
        // Textを中央寄せにする.
        timerLabel.textAlignment = NSTextAlignment.center
        // ViewにLabelを追加.
        self.view.addSubview(timerLabel)
        
        buttonsStartY = nextY
        
        displayFirstButton()
        
        // リセットButtonを生成する.
        resetButton = UIButton()
        // サイズを設定する.
        resetButton.frame = CGRect(x: edge,y: nextY,width: (screenWidth-interval)/2-edge, height: buttonHeight - 10)
        // 背景色を設定する.
        resetButton.backgroundColor = UIColor.red
        // 枠を丸くする.
        resetButton.layer.masksToBounds = true
        // タイトルを設定する(通常時).
        resetButton.setTitle("reset", for: UIControlState())
        resetButton.setTitleColor(UIColor.white, for: UIControlState())
        // コーナーの半径を設定する.
        resetButton.layer.cornerRadius = 15.0
        // イベントを追加する.
        resetButton.addTarget(self, action: #selector(ViewController.onClickResetButton), for: .touchUpInside)
        
        // ボタンをViewに追加する.
        self.view.addSubview(resetButton)
        
        // シャアButtonを生成する.
        shareButton = UIButton()
        // サイズを設定する.
        shareButton.frame = CGRect(x: (screenWidth-interval)/2 + interval ,y: nextY,width: (screenWidth-interval)/2-edge, height: buttonHeight - 10)
        // 背景色を設定する.
        shareButton.backgroundColor = UIColor.blue
        // 枠を丸くする.
        shareButton.layer.masksToBounds = true
        // タイトルを設定する(通常時).
        shareButton.setTitle("share the Score", for: UIControlState())
        shareButton.setTitleColor(UIColor.white, for: UIControlState())
        // コーナーの半径を設定する.
        shareButton.layer.cornerRadius = 15.0
        // 透明化
        shareButton.isHidden = true
        // 無効化
        shareButton.isEnabled = false
        // イベントを追加する.
        shareButton.addTarget(self, action: #selector(ViewController.onClickShareButton), for: .touchUpInside)
        
        // ボタンをViewに追加する.
        self.view.addSubview(shareButton)
        
        // AdMob広告設定
        var bannerView: GADBannerView = GADBannerView()
        bannerView = GADBannerView(adSize:kGADAdSizeBanner)
        bannerView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - bannerView.frame.height)
        bannerView.frame.size = CGSize(width: self.view.frame.width, height: bannerView.frame.height)
        // AdMobで発行された広告ユニットIDを設定
        bannerView.adUnitID = "ca-app-pub-4040761063524447/9963574614"
        bannerView.delegate = self
        bannerView.rootViewController = self
        bannerView.adSize = kGADAdSizeSmartBannerLandscape
        let gadRequest:GADRequest = GADRequest()
        bannerView.load(gadRequest)
        self.view.addSubview(bannerView)
        
    }
    
    func onClickResetButton() {
        
        timer.invalidate()
        
        shareButton.isHidden = true
        shareButton.isEnabled = false
        
        displayFirstButton()
        
        
    }
    
    // NSTimerIntervalで指定された秒数毎に呼び出されるメソッド.
    func onUpdate(_ timer : Timer){
        
        cnt = cnt - 0.01
        
        //桁数を指定して文字列を作る.
        let str = "Time:".appendingFormat("%.2f",cnt)
        
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
        let labelStr = "YourScore:" + String(score) + "p, Correct:".appendingFormat("%.1f",Float(index0)/Float(answerArray.count)*100) + "%"
        scoreLabel.text = labelStr
        print(labelStr)
        
        let count = self.buttonArray.count
        for i in 0 ..< count {
            buttonArray[i]?.isEnabled = true
            buttonArray[i]?.removeTarget(self, action:#selector(ViewController.onClickMyButton(_:)), for: .touchUpInside)
            buttonArray[i]?.addTarget(self, action: #selector(ViewController.displayFirstButton), for: .touchUpInside)
        }
        
        shareButton.isHidden = false
        shareButton.isEnabled = true
        
        setDataToFirebase(String(score))
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
            self.buttonArray[i]?.removeFromSuperview()
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
                firstButton.frame = CGRect(x: startX, y: startY,width: length,height: length)
                
                if x == 0 && y == 4 {
                    nextY = startY + length + edge
                }
                
                // 背景色を設定する.
                firstButton.backgroundColor = UIColor(red: r/256, green: g/256, blue: b/256, alpha: 1.0) //UIColor.redColor()
                
                // 枠を丸くする.
                firstButton.layer.masksToBounds = true
                
                // タイトルを設定する(通常時).
                firstButton.setTitle("", for: UIControlState())
                firstButton.setTitleColor(UIColor.white, for: UIControlState())
                
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
                firstButton.addTarget(self, action: #selector(ViewController.onClickFirstButton), for: .touchUpInside)
                
                buttonArray.append(firstButton)
                
                // ボタンをViewに追加する.
                self.view.addSubview(firstButton)
                
            }
        }
        
        buttonArray[12]?.setTitle("S", for: UIControlState())
        buttonArray[13]?.setTitle("T", for: UIControlState())
        buttonArray[14]?.setTitle("A", for: UIControlState())
        buttonArray[15]?.setTitle("R", for: UIControlState())
        buttonArray[16]?.setTitle("T", for: UIControlState())
        buttonArray[17]?.setTitle("!", for: UIControlState())
        timerLabel.text = "in 30 second"
        scoreLabel.text = "GET HIGH SCORE"
        
        timer = Timer(timeInterval: 0.01, target: self, selector: #selector(ViewController.onUpdate(_:)), userInfo: nil, repeats: true)
        
        
    }
    
    func displayButton(_ numOfRow: Int, _ numOfColumn: Int) {
        
        // button 初期化
        let count = self.buttonArray.count
        for i in 0 ..< count {
            self.buttonArray[i]?.removeFromSuperview()
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
                firstButton.frame = CGRect(x: startX, y: startY,width: length,height: length)
                // 枠を丸くする.
                firstButton.layer.masksToBounds = true
                // 枠を透明にする
                firstButton.layer.borderColor = UIColor.clear.cgColor
                // タイトルを設定する(通常時).
                firstButton.setTitle("", for: UIControlState())
                firstButton.setTitleColor(UIColor.white, for: UIControlState())
                // コーナーの半径を設定する.
                firstButton.layer.cornerRadius = 20.0
                
                // タグを設定する.
                let tagNum = x + (y * numOfRow) + 1
                firstButton.tag = tagNum
                
                // 一つだけ色を変える
                if tagNum == difNum {
                    var rgbArray: [CGFloat?] = [r,g,b]
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
                    
                    firstButton.backgroundColor = UIColor(red: rgbArray[0]!/256, green: rgbArray[1]!/256, blue: rgbArray[2]!/256, alpha: 1.0)
                } else {
                    firstButton.backgroundColor = UIColor(red: r/256, green: g/256, blue: b/256, alpha: 1.0)
                }
                
                // イベントを追加する.
                firstButton.addTarget(self, action: #selector(ViewController.onClickMyButton(_:)), for: .touchUpInside)
                
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
        
        shareButton.isHidden = true
        shareButton.isEnabled = false
        
        scoreLabel.text = "Ready??"
        
        // 遅延
        let delayTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            
            self.scoreLabel.text = "Start!!"
            
            self.displayButton(6, 5)
            
            if let timer = self.timer {
                RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
            }

        }
        
    }
    
    func onClickMyButton(_ sender: UIButton){
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
            btn?.isEnabled = false
        }
        
        // 正解のボタンに枠をつける
        buttonArray[difNum-1]?.layer.borderColor = UIColor.black.cgColor
        buttonArray[difNum-1]?.layer.borderWidth = 3.0
        
        if cnt > 0.3 {
            
            // 遅延
            let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                
                self.displayButton(6, 5)
                
                self.scoreLabel.text = "Now Score: \(self.score)p!!"
            }
        }
        
    }
    
    func onClickShareButton() {
        
        let alert = UIAlertController(title: "select SNS type", message: "share the Score", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Twitter", style: .default, handler: { action in
            self.shareInTwitter()
        }))
        alert.addAction(UIAlertAction(title: "Facebook", style: .default, handler: { action in
            self.shareInFacebook()
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)

        
    }
    
    func shareInTwitter() {
        let text = "I got \(self.score)point!! #ColorTest "
        let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
        composeViewController.setInitialText(text)
        composeViewController.add(itunesUrl as URL!)
        self.present(composeViewController, animated: true, completion: nil)
    }
    
    func shareInFacebook() {
        let text = "I got \(self.score)point!! #ColorTest "
        let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
        composeViewController.setInitialText(text)
        composeViewController.add(itunesUrl as URL!)
        self.present(composeViewController, animated: true, completion: nil)
    }
    
    func setDataToFirebase(_ score: String) {
        
        // 時刻を取得
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium // -> ex: 2016/10/29
        formatter.timeStyle = .medium // -> ex: 13:20:08
        
        let formattedDate = formatter.string(from: now)
        
        ref.childByAutoId().setValue(["score": score,
                                      "date": formattedDate])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension ViewController: GADBannerViewDelegate {
    
    // Called when an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called when an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(#function): \(error.localizedDescription)")
    }
    
    // Called just before presenting the user a full screen view, such as a browser, in response to
    // clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before dismissing a full screen view.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just after dismissing a full screen view.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before the application will background or terminate because the user clicked on an
    // ad that will launch another application (such as the App Store).
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print(#function)
    }
}


