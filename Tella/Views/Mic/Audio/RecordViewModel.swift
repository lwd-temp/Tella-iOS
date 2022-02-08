//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class RecordViewModel: ObservableObject {
    
    @Published var state: RecordState = .ready
    @Published var fileName: String = ""
    @Published var time: String = ""

    private var audioBackend: RecordingAudioManager = RecordingAudioManager()
    private var cancellable: Set<AnyCancellable> = []

    var mainAppModel: MainAppModel? {
        didSet {
            audioBackend.mainAppModel = mainAppModel
        }
    }
    
    init() {

        audioBackend.currentTime.sink { value in
            self.time = value.stringFromTimeInterval()
        }.store(in: &cancellable)
        
        self.fileName = self.initialFileName
    }
    
    // Record audio

    func onStartRecording() {

        self.state = .recording
        
        self.audioBackend.startRecording()
        
        self.updateView()
    }
    
    func onPauseRecord() {

        self.audioBackend.pauseRecording()

        self.state = .paused
        
        self.updateView()

    }
    
    func onResumeRecording() {

        self.state = .recording
        
        self.audioBackend.startRecording()
        
        self.updateView()
    }


    func onStopRecording() {
        self.state = .ready
        
        self.audioBackend.stopRecording(fileName: fileName)
        
        self.fileName = self.initialFileName

        self.updateView()
    }
    
    func onResetRecording() {
          self.audioBackend.resetRecorder()
 
     }

    
    
    
    // Play audio
    func onPlayRecord() {
        self.audioBackend.playRecord()
    }

    func onStopRecord() {
        self.audioBackend.pauseRecord()
    }

    
    fileprivate func updateView() {
        self.objectWillChange.send()
    }
    
    // "Recording 2020.06.24-16.45"
   
    var initialFileName: String {
        return  "Recording " + Date().getFormattedDateString(format: DateFormat.fileName.rawValue)
    }
    
}
