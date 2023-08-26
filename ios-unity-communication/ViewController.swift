//
//  ViewController.swift
//  ios-unity-communication
//
//  Created by Betül Çalık on 26.08.2023.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Components
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        UnityManager.shared.delegate = self
        
        redButton.layer.cornerRadius = redButton.frame.height / 2
        blueButton.layer.cornerRadius = blueButton.frame.height / 2
        greenButton.layer.cornerRadius = greenButton.frame.height / 2
    }

    // MARK: - Actions
    @IBAction func didRedButtonTap(_ sender: UIButton) {
        UnityManager.shared.show()
        UnityManager.shared.sendMessage("Ball",
                                        methodName: "SetBallColor",
                                        message: "red")
    }
    
    @IBAction func didBlueButtonTap(_ sender: UIButton) {
        UnityManager.shared.show()
        UnityManager.shared.sendMessage("Ball",
                                        methodName: "SetBallColor",
                                        message: "blue")
    }
    
    @IBAction func didGreenButtonTap(_ sender: UIButton) {
        UnityManager.shared.show()
        UnityManager.shared.sendMessage("Ball",
                                        methodName: "SetBallColor",
                                        message: "green")
    }
    
}

extension ViewController: UnityManagerDelegate {
    
    func didButtonPress(message: String) {
        let unityVC = UnityManager.shared.getUnityRootVC()
        let alert = UIAlertController(title: "Message From Unity",
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        unityVC?.present(alert, animated: true, completion: nil)
    }
    
}
