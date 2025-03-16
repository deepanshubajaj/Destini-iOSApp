//
//  DestiniController.swift
//  Destini
//
//  Created by Deepanshu Bajaj on 08/12/24.
//

import UIKit
import AVFoundation

class DestiniController: UIViewController {
    
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var choice1Button: UIButton!
    @IBOutlet weak var choice2Button: UIButton!
    
    var storyBrain = StoryBrain()
    var player: AVAudioPlayer?
    var choiceMadePlayer: AVAudioPlayer?
    var isMuted = false // Track the mute state
    var muteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playSound(soundName: "chopin-waltz-no-10-op-69-no-2-239268-audio", soundFileExtension: "mp3")
        
        handleAppState()
        setupMuteButton()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showWelcomeAlert()
    }
    
    @IBAction func choiceMade(_ sender: UIButton) {
        playChoiceMadeSound(soundName: "choiceMadeAudio", soundFileExtension: "mp3")
        storyBrain.nextStory(userChoice: sender.currentTitle!)
        
        if storyBrain.getChoiceDestination() == 0 {
            showPlayAgainAlert()
        }
        
        updateUI()
    }
    
    @objc func toggleMute() {
        isMuted.toggle() // Toggle mute state
        updateMuteButtonImage()
        updateVolume()
    }
    
    func playSound(soundName: String, soundFileExtension: String) {
        let url = Bundle.main.url(forResource: soundName, withExtension: soundFileExtension)
        do {
            player = try AVAudioPlayer(contentsOf: url!)
            player?.numberOfLoops = -1
            player?.play()
        } catch {
            print("Error initializing audio player: \(error)")
        }
    }
    
    func playChoiceMadeSound(soundName: String, soundFileExtension: String) {
        let url = Bundle.main.url(forResource: soundName, withExtension: soundFileExtension)
        do {
            choiceMadePlayer = try AVAudioPlayer(contentsOf: url!)
            choiceMadePlayer?.play() // Play "choicemade" sound once
        } catch {
            print("Error initializing choiceMadePlayer: \(error)")
        }
    }
    
    func pauseSound() {
        player?.pause() // Pause the sound
    }
    
    func resumeSound() {
        if let player = player, !player.isPlaying {
            player.play() // Resume the sound
        }
    }
    
    @objc func appMovedToBackground() {
        pauseSound()
    }
    
    @objc func appMovedToForeground() {
        resumeSound()
    }
    
    func showWelcomeAlert() {
        let welcomeAlert = UIAlertController(title: "Welcome to Destini", message: "Make your Choices Wisely with no Regrets!", preferredStyle: .alert)
        
        let enterAction = UIAlertAction(title: "Enter", style: .default) { _ in
            // Welcome Alert Dismiss
        }
        
        welcomeAlert.addAction(enterAction)
        present(welcomeAlert, animated: true, completion: nil)
    }
    
    func showPlayAgainAlert() {
        let alert = UIAlertController(title: "The End", message: "Would you like to play again?", preferredStyle: .alert)
        
        let playAgainAction = UIAlertAction(title: "Play Again", style: .default) { _ in
            self.storyBrain.storyNumber = 0
            self.updateUI()
            self.showWelcomeAlert()
        }
        
        let nextTimeAction = UIAlertAction(title: "Next Time", style: .destructive) { _ in
            self.showCloseAppAlert()
        }
        
        alert.addAction(playAgainAction)
        alert.addAction(nextTimeAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showCloseAppAlert() {
        let alert = UIAlertController(title: "Goodbye 👋", message: "Please close the app manually.", preferredStyle: .alert)
        
        // Create a full-screen overlay view to capture all interactions
        let overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.backgroundColor = UIColor.clear
        overlayView.isUserInteractionEnabled = true
        
        // For iOS 13+ (multiple scenes)
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.addSubview(overlayView)
            }
        } else {
            // For iOS 12 and below (single key window)
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.addSubview(overlayView)
            }
        }
        
        present(alert, animated: true) {
            // Disable interaction with the alert itself (to prevent dismissal)
            alert.view.superview?.isUserInteractionEnabled = false
            alert.view.superview?.subviews.first?.isUserInteractionEnabled = false
        }
    }
    
    func handleAppState() {
        // Observe when app moves to the background
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Observe when app returns to the foreground
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func updateUI() {
        storyLabel.text = storyBrain.getStoryTitle()
        choice1Button.setTitle(storyBrain.getChoice1(), for: .normal)
        choice2Button.setTitle(storyBrain.getChoice2(), for: .normal)
    }
    
    func updateVolume() {
        player?.volume = isMuted ? 0 : 1
    }
    
    func updateMuteButtonImage() {
        let imageName = isMuted ? "unmuteIcon" : "muteIcon"
        muteButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func setupMuteButton() {
        // Mute Button
        muteButton = UIButton(type: .system)
        
        let initialImageName = isMuted ? "unmuteIcon" : "muteIcon"
        muteButton.setImage(UIImage(named: initialImageName), for: .normal)
        muteButton.addTarget(self, action: #selector(toggleMute), for: .touchUpInside)
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(muteButton)
        
        // Constraints to position the button on the right side
        NSLayoutConstraint.activate([
            muteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            muteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            muteButton.widthAnchor.constraint(equalToConstant: 20),
            muteButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
