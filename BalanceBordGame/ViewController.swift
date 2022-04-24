//
//  ViewController.swift
//  BalanceBordGame
//
//  Created by Daniil on 23.04.2022.
//

import Combine
import UIKit

class ViewController: UIViewController {
    private enum Direction {
        case left
        case right
    }
    
    @IBOutlet weak var loseView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var endGamePointsLabel: UILabel!
    
    private var duration: Double = 0.016
    private var direction: Direction = .right
    private var currentAngle: CGFloat = .pi
    
    private var points = 0
    
    private var pointsSubscription: AnyCancellable?
    private var reduceIntervalSubscription: AnyCancellable?
    private var gameTimerSubscription: AnyCancellable?

    @IBAction func leftAction(_ sender: Any) {
        direction = .left
    }

    @IBAction func rightAction(_ sender: Any) {
        direction = .right
    }

    @IBAction func restartAction(_ sender: Any) {
        imageView.transform = .identity
        duration = 0.016
        direction = .right
        currentAngle = .pi
        loseView.isHidden = true
        setPoints(value: 0)
        
        startGame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGame()
    }
    
    private func startGame() {
        startPointsTimer()
        makeReduceInterval()
        startGameTimer()
    }
    private func startPointsTimer() {
        pointsSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.setPoints(value: self.points + 1)
            })
    }
    
    private func makeReduceInterval() {
        reduceIntervalSubscription = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                guard
                    let self = self,
                    self.duration > 0.001
                else {
                    return
                }
                self.duration -= 0.001
                self.startGameTimer()
            })
    }

    private func startGameTimer() {
        gameTimerSubscription = Timer.publish(every: duration, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else {
                    return
                }
                let nextAngle = self.direction == .right ? self.currentAngle + 1 : self.currentAngle - 1

                guard abs(nextAngle) < 90 && abs(nextAngle) > 0 else {
                    self.loseView.isHidden = false
                    self.pointsSubscription = nil
                    self.endGamePointsLabel.text = "Ваш счет: \(self.points)"
                    return
                }

                self.imageView.transform = .identity
                self.imageView.transform = .init(rotationAngle: nextAngle * CGFloat.pi / 180)
                self.currentAngle = nextAngle
            })
    }
    
    private func setPoints(value: Int) {
        points = value
        pointsLabel.text = "Очки: \(self.points)"
    }
}

