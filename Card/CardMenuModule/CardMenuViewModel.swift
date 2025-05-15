import SwiftUI

class CardMenuViewModel: ObservableObject {
    let contact = CardMenuModel()
    @Published var isFirstGame = false
    @Published var isSecondGame = false
    @Published var isThirdGame = false
    @Published var isDaily = false
    @Published var isMusic: Bool {
        didSet {
            UserDefaults.standard.set(isMusic, forKey: "isMusic")
        }
    }
    
    @Published var isSound: Bool {
        didSet {
            UserDefaults.standard.set(isSound, forKey: "isSound")
        }
    }
    
    init() {
        self.isMusic = UserDefaults.standard.bool(forKey: "isMusic")
        self.isSound = UserDefaults.standard.bool(forKey: "isSound")
        updateRemainingTime()
        startTimer()
    }
    
    private let key = "lastTransitionDate"
    private let cooldownInterval: TimeInterval = 24 * 60 * 60
    
    @Published var remainingTime: TimeInterval = 0
    
    private var timer: Timer?
    
    func recordTransition() {
        let now = Date()
        UserDefaults.standard.set(now, forKey: key)
        updateRemainingTime()
    }
    
    func canTransition() -> Bool {
        remainingTime <= 0
    }
    
    private func updateRemainingTime() {
        if let lastDate = UserDefaults.standard.object(forKey: key) as? Date {
            let elapsed = Date().timeIntervalSince(lastDate)
            remainingTime = max(cooldownInterval - elapsed, 0)
        } else {
            remainingTime = 0
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func formattedRemainingTime() -> String {
        let totalSeconds = Int(remainingTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        // Можно добавить секунды, если нужно
        return String(format: "%02d:%02d", hours, minutes)
    }
}
