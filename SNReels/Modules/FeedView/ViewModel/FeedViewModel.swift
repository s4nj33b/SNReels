//
//  FeedViewModel.swift
//  SNReels
//
//  Created by Sanjeeb on 05/04/21.
//

import Foundation
import AVFoundation

class FeedViewModel: NSObject {
    private var docs = [Feed]()
    override init() {
        super.init()
    }
    
    func setAudioMode() {
        do {
            try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch (let err){
            print("setAudioMode error:" + err.localizedDescription)
        }
        
    }
    
    /*
     1. Make API Calls for get feed data form server
     2. append those data to Feed Model and Feed View model
     */
    
    func getFeed() -> [Feed] {
    
        docs.append(Feed(videoUrl: URL(string: "https://res.cloudinary.com/byosocial/video/upload/q_60/v1576476056/OnBoardingScreens/launch_onboarding_1.mp4")!, videoFileExtension: "mp4"))
        docs.append(Feed(videoUrl: URL(string: "https://res.cloudinary.com/byosocial/video/upload/q_60/v1576476056/OnBoardingScreens/launch_onboarding_2.mp4")!, videoFileExtension: "mp4"))
        docs.append(Feed(videoUrl: URL(string: "https://res.cloudinary.com/byosocial/video/upload/q_60/v1576476056/OnBoardingScreens/launch_onboarding_3.mp4")!, videoFileExtension: "mp4"))
        docs.append(Feed(videoUrl: URL(string: "https://res.cloudinary.com/byosocial/video/upload/q_60/v1576476056/OnBoardingScreens/launch_onboarding_4.mp4")!, videoFileExtension: "mp4"))
        
        return docs
    }
}
