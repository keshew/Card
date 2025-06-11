import SwiftUI
import Combine

class CardMenuViewModel: ObservableObject {
    let contact = CardMenuModel()
    
    @Published var isFirstGame = false
    @Published var isSecondGame = false
    @Published var isThirdGame = false
    @Published var isDaily = false
    @Published var nameFirstGame = ""
    
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
    
    @Published var remainingTime: TimeInterval = 0
    @Published var canGetBonus: Bool = false
    
    private var timer: Timer?
    private let networkManager = NetworkManager()
    
    let adjustHandler: AdjustHandler
    
    init(adjustHandler: AdjustHandler) {
          self.adjustHandler = adjustHandler
        self.isMusic = UserDefaults.standard.bool(forKey: "isMusic")
        self.isSound = UserDefaults.standard.bool(forKey: "isSound")
        
        fetchBonusStatus()
        
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.fetchBonusStatus()
        }
    }
    
    func fetchBonusStatus() {
        networkManager.checkBonusStatus { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let status):
                    self?.canGetBonus = status.canGetBonus || status.remainingSeconds <= 0
                    self?.remainingTime = TimeInterval(status.remainingSeconds)
                case .failure(let error):
                    print("Ошибка при получении статуса бонуса: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func recordTransition() {
        networkManager.startBonus { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self?.canGetBonus = false
                        self?.remainingTime = TimeInterval(response.nextAvailableIn ?? 24 * 60 * 60)
                    } else {
                        if let remaining = response.nextAvailableIn {
                            self?.remainingTime = TimeInterval(remaining)
                        }
                    }
                case .failure(let error):
                    print("Ошибка при попытке получить бонус: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func formattedRemainingTime() -> String {
        let totalSeconds = Int(remainingTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    func canTransition() -> Bool {
        canGetBonus || remainingTime <= 0 
    }
    
    @Published var isLoaded = false
    @Published var managerKey: String? = nil
    
    func setup() async {
        await checkIfManager()
    }
}
