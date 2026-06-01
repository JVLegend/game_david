import AVFoundation

final class AudioManager {
    static let shared = AudioManager()

    private var musicPlayer: AVAudioPlayer?
    private var currentTrackName: String?
    private let musicEnabledKey = "music_enabled"
    private let soundEnabledKey = "sound_enabled"

    private let mapMusicTracks: [Int: String] = [
        1: "music_bethlehem_fields",
        2: "music_valley_elah",
        3: "music_saul_court",
        4: "music_en_gedi",
        5: "music_philistine_land",
        6: "music_jerusalem_siege",
        7: "music_throne_israel",
    ]

    var isMusicEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: musicEnabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: musicEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: musicEnabledKey)
            newValue ? resumeMusic() : pauseMusic()
        }
    }

    var isSoundEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: soundEnabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: soundEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: soundEnabledKey)
        }
    }

    private init() {
        configureSession()
    }

    func playMenuMusic() {
        playMusic(named: "lofi_menu_loop", volume: 0.35)
    }

    func playMapMusic(mapId: Int) {
        let trackName = mapMusicTracks[mapId] ?? "music_bethlehem_fields"
        playMusic(named: trackName, volume: 0.38)
    }

    func playMusic(named trackName: String, fileExtension: String = "m4a", volume: Float = 0.45) {
        if !isMusicEnabled {
            currentTrackName = trackName
            return
        }

        if currentTrackName == trackName, musicPlayer?.isPlaying == true {
            return
        }

        guard let url = Bundle.main.url(forResource: trackName, withExtension: fileExtension) else {
            print("AudioManager: music file not found: \(trackName).\(fileExtension)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = volume
            player.prepareToPlay()
            player.play()

            musicPlayer = player
            currentTrackName = trackName
        } catch {
            print("AudioManager: failed to play \(trackName).\(fileExtension): \(error)")
        }
    }

    func pauseMusic() {
        musicPlayer?.pause()
    }

    func resumeMusic() {
        if musicPlayer == nil {
            playMusic(named: currentTrackName ?? "lofi_menu_loop")
            return
        }
        musicPlayer?.play()
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioManager: failed to configure audio session: \(error)")
        }
    }
}
