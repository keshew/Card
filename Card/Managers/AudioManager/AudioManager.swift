import AVFoundation
import SwiftUI

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    var bgPlayer: AVAudioPlayer?
    var winPlayer: AVAudioPlayer?
    
    @Published var backgroundVolume: Float = 1 {
        didSet {
            bgPlayer?.volume = backgroundVolume
        }
    }
    
    @Published var soundEffectVolume: Float = 1 {
        didSet {
            
        }
    }
    
    @Published var isSoundEnabled: Bool = true
    @Published var isMusicEnabled: Bool = true

    init() {
        self.isSoundEnabled = UserDefaultsManager().isSoundEnabled()
        self.isMusicEnabled = UserDefaultsManager().isMusicEnabled()
        
        loadBackgroundMusic()
        
        if isMusicEnabled {
            playBackgroundMusic()
        }
    }

    private func loadBackgroundMusic() {
        if let url = Bundle.main.url(forResource: "bg", withExtension: "wav") {
            do {
                bgPlayer = try AVAudioPlayer(contentsOf: url)
                bgPlayer?.numberOfLoops = -1
                bgPlayer?.volume = backgroundVolume
                bgPlayer?.prepareToPlay()
            } catch {
                print("Ошибка \(error)")
            }
        }
    }
    
    private func loadWibMusic() {
        if let url = Bundle.main.url(forResource: "win", withExtension: "mp3") {
            do {
                winPlayer = try AVAudioPlayer(contentsOf: url)
                winPlayer?.numberOfLoops = -1
                winPlayer?.volume = backgroundVolume
                bgPlayer?.prepareToPlay()
            } catch {
                print("Ошибка \(error)")
            }
        }
    }
    
    func playBackgroundMusic() {
        if isMusicEnabled {
            bgPlayer?.play()
        }
    }
    
    func stopBackgroundMusic() {
        bgPlayer?.stop()
    }
    
    func playWinMusic() {
        if isMusicEnabled {
            winPlayer?.play()
        }
    }
    
    func stopWinMusic() {
        winPlayer?.stop()
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
        UserDefaultsManager().saveSoundSettings(isSoundEnabled: isSoundEnabled)
    }
    
    func toggleMusic() {
        isMusicEnabled.toggle()
        if isMusicEnabled {
            playBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
        UserDefaultsManager().saveMusicSettings(isMusicEnabled: isMusicEnabled)
    }
}
