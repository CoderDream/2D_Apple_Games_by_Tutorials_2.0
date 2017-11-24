/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import WatchKit
import Foundation
import SpriteKit
import CoreMotion

class InterfaceController: WKInterfaceController, WKCrownDelegate {
  
  @IBOutlet var skInterface: WKInterfaceSKScene!
  var gameScene: GameScene!
  let motionManager = CMMotionManager()
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(loadScene),
                                           name: NSNotification.Name("Reload"), object: nil)
    
    motionManager.accelerometerUpdateInterval = 1.0/30.0
    loadScene()
  }
  
  @objc func loadScene() {
    gameScene = GameScene(fileNamed:"GameScene")
    gameScene.scaleMode = .aspectFill
    let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
    skInterface.presentScene(gameScene, transition: reveal)
    skInterface.preferredFramesPerSecond = 30
  }
  
  @IBAction func didTap(_ sender: Any) {
    // forward to the gameScene
    gameScene.didTap(sender as! WKTapGestureRecognizer)
  }
  
  @IBAction func didSwipe(_ sender: Any) {
    // forward to the gameScene
    gameScene.didSwipe(sender as! WKSwipeGestureRecognizer)
  }
  
  func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
    let rotateSpeed = CGFloat(
      crownSequencer!.rotationsPerSecond)
    if rotateSpeed != 0.0 {
      gameScene.reelTurn(rotateSpeed: rotateSpeed)
    }
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    crownSequencer.delegate = self
    crownSequencer.focus()
    
    if motionManager.isAccelerometerAvailable {
      motionManager.startAccelerometerUpdates(
        to: OperationQueue.current!,
        withHandler: { data, error in
          guard let data = data else { return }
          self.gameScene.accelerometerUpdate(accelerometerData: data)
      })
    }
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
    motionManager.stopAccelerometerUpdates()
  }
  
}
