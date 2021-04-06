//
//  FeedTableViewCell.swift
//  SNReels
//
//  Created by Sanjeeb on 05/04/21.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    private var playerView: VideoView!
    
    
    // MARK: - Variables
    private var feed: Feed?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        playerView = VideoView()
        _ = self.addFitting(subView: playerView)

    }
    
    // MARK: LIfecycles
    override func prepareForReuse() {
        super.prepareForReuse()
        playerView.cancelAllLoadingRequest()
    }
    
    func setup(feed: Feed) {
        self.feed = feed
        playerView.configure(url: feed.videoUrl, fileExtension: feed.videoFileExtension)
    }
    
    func replay(){
        playerView.replay()
    }
    
    func play() {
        playerView.togglePlay(on: true)
       
    }
    
    func pause(){
        playerView.togglePlay(on: false)
    }
}

