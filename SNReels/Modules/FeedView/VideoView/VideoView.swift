//
//  VideoView.swift
//  SNReels
//
//  Created by Sanjeeb on 05/04/21.
//
import AVKit
import UIKit

final class VideoView: UIView {
    
    private var looper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    private let playerLayer = AVPlayerLayer()
    
    
    private var observer: NSKeyValueObservation?
    
    private var session: URLSession?
    private var loadingRequests = [AVAssetResourceLoadingRequest]()
    private var task: URLSessionDataTask?
    private var infoResponse: URLResponse?
    private var cancelLoadingQueue: DispatchQueue?
    private var videoData: Data?
    private var fileExtension: String?
    private var videoURL: URL?
    private var originalURL: URL?
    private var asset: AVURLAsset?
    
    private var isPlaying: Bool {
        queuePlayer?.rate != 0
    }
    
    override var isUserInteractionEnabled: Bool {
        get { true }
        set {}
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSelf()
        setupOperaions()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        removeObserver()
    }
    
    private func setupSelf() {
        backgroundColor = .white
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTap))
        addGestureRecognizer(tapRecognizer)
        
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        playerLayer.frame = layer.bounds
    }
    
    func prepareVideo(at path: String) {
        let url = URL(fileURLWithPath: path)
        prepareVideo(at: url)
    }
    
    func prepareVideo(at url: URL) {
        self.asset = AVURLAsset(url: url)
        self.asset!.resourceLoader.setDelegate(self, queue: .main)
        
        let playerItem = AVPlayerItem(asset: asset!)
        addObserverToPlayerItem()
        
        let player = AVQueuePlayer(playerItem: playerItem)
        queuePlayer = player
        playerLayer.player = queuePlayer
        looper = AVPlayerLooper(player: player, templateItem: playerItem)
    }
    
    @objc
    private func didReceiveTap() {
        togglePlay()
    }
    
    func togglePlay(on: Bool? = nil) {
        if let on = on {
            on ? queuePlayer?.play() : queuePlayer?.pause()
        } else if isPlaying {
            queuePlayer?.pause()
        } else {
            queuePlayer?.play()
        }
    }
    
    func replay(){
        self.queuePlayer?.seek(to: .zero)
        queuePlayer?.play()
    }
    
    func configure(url: URL, fileExtension: String) {
       
        self.fileExtension = fileExtension
        
        VideoCacheManager.shared.queryURLFromCache(key: url.absoluteString, fileExtension: fileExtension, completion: {[weak self] (data) in
            DispatchQueue.main.async { [weak self] in
                guard let blockSelf = self else { return }
                if let path = data as? String {
                    blockSelf.videoURL = URL(fileURLWithPath: path)
                } else {
                    // Adding Redirect URL(customized prefix schema) to trigger AVAssetResourceLoaderDelegate
                    guard let redirectUrl = url.convertToRedirectURL(scheme: "streaming") else {
                        print("\(url)\nCould not convert the url to a redirect url.")
                        return
                    }
                    blockSelf.videoURL = redirectUrl
                }
                
                blockSelf.originalURL = url
                blockSelf.prepareVideo(at: blockSelf.videoURL!)
            }
        })
    }
    func setupOperaions() {
        let operationQueue = OperationQueue()
        operationQueue.name = "com.VideoPlayer.URLSeesion"
        operationQueue.maxConcurrentOperationCount = 1
        session = URLSession.init(configuration: .default, delegate: self, delegateQueue: operationQueue)
        cancelLoadingQueue = DispatchQueue.init(label: "com.cancelLoadingQueue")
        videoData = Data()
    }
    
    func cancelAllLoadingRequest() {
        removeObserver()
        
        videoURL = nil
        originalURL = nil

        playerLayer.player = nil
        looper = nil
        
        cancelLoadingQueue?.async { [weak self] in
            self?.session?.invalidateAndCancel()
            self?.session = nil
            
            self?.asset?.cancelLoading()
            self?.task?.cancel()
            self?.task = nil
            self?.videoData = nil
            
            self?.loadingRequests.forEach { $0.finishLoading() }
            self?.loadingRequests.removeAll()
        }

    }
    
    
}

// MARK: - KVO
extension VideoView {
    
    func removeObserver() {
        if let observer = observer {
            observer.invalidate()
        }
    }
    
    fileprivate func addObserverToPlayerItem() {
        // Register as an observer of the player item's status property
        self.observer = self.queuePlayer?.currentItem!.observe(\.status, options: [.initial, .new], changeHandler: { item, _ in
            let status = item.status
            // Switch over the status
            switch status {
            case .readyToPlay:
                print("Status: readyToPlay")
            case .failed:
                print("Status: failed Error: " + item.error!.localizedDescription )
            case .unknown:
                print("Status: unknown")
            @unknown default:
                fatalError("Status is not yet ready to present")
            }
        })
    }
}
// MARK: - URL Session Delegate
extension VideoView: URLSessionTaskDelegate, URLSessionDataDelegate {
    // Get Responses From URL Request
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.infoResponse = response
        self.processLoadingRequest()
        completionHandler(.allow)
    }
    
    // Receive Data From Responses and Download
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.videoData?.append(data)
        self.processLoadingRequest()
    }
    
    // Responses Download Completed
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("AVURLAsset Download Data Error: " + error.localizedDescription)
        } else {
            VideoCacheManager.shared.storeDataToCache(data: self.videoData, key: self.originalURL!.absoluteString, fileExtension: self.fileExtension)
        }
    }
    
    private func processLoadingRequest(){
        var finishedRequests = Set<AVAssetResourceLoadingRequest>()
        self.loadingRequests.forEach {
            var request = $0
            if self.isInfo(request: request), let response = self.infoResponse {
                self.fillInfoRequest(request: &request, response: response)
            }
            if let dataRequest = request.dataRequest, self.checkAndRespond(forRequest: dataRequest) {
                finishedRequests.insert(request)
                request.finishLoading()
            }
        }
        self.loadingRequests = self.loadingRequests.filter { !finishedRequests.contains($0) }
    }
    
    private func fillInfoRequest(request: inout AVAssetResourceLoadingRequest, response: URLResponse) {
        request.contentInformationRequest?.isByteRangeAccessSupported = true
        request.contentInformationRequest?.contentType = response.mimeType
        request.contentInformationRequest?.contentLength = response.expectedContentLength
    }
    
    private func isInfo(request: AVAssetResourceLoadingRequest) -> Bool {
         return request.contentInformationRequest != nil
     }
    
    private func checkAndRespond(forRequest dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
        guard let videoData = videoData else { return false }
        let downloadedData = videoData
        let downloadedDataLength = Int64(downloadedData.count)

        let requestRequestedOffset = dataRequest.requestedOffset
        let requestRequestedLength = Int64(dataRequest.requestedLength)
        let requestCurrentOffset = dataRequest.currentOffset

        if downloadedDataLength < requestCurrentOffset {
            return false
        }

        let downloadedUnreadDataLength = downloadedDataLength - requestCurrentOffset
        let requestUnreadDataLength = requestRequestedOffset + requestRequestedLength - requestCurrentOffset
        let respondDataLength = min(requestUnreadDataLength, downloadedUnreadDataLength)

        dataRequest.respond(with: downloadedData.subdata(in: Range(NSMakeRange(Int(requestCurrentOffset), Int(respondDataLength)))!))

        let requestEndOffset = requestRequestedOffset + requestRequestedLength

        return requestCurrentOffset >= requestEndOffset

    }
}

// MARK: - AVAssetResourceLoader Delegate
extension VideoView: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if task == nil, let url = originalURL {
            let request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
            task = session?.dataTask(with: request)
            task?.resume()
        }
        self.loadingRequests.append(loadingRequest)
        return true
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        if let index = self.loadingRequests.firstIndex(of: loadingRequest) {
            self.loadingRequests.remove(at: index)
        }
    }
}
