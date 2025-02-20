//
//  TTPlayerViewController.swift
//  TTPlayerDecryptDemo
//

import TTSDK
import UIKit
import SnapKit
import DRMLib

class TTPlayerViewController: UIViewController {
    private let videoUrl: String
    private let engine: TTVideoEngine = .init(ownPlayer: true)
    
    init(url: String) {
        self.videoUrl = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
         
        // add subview
        let playerView = engine.playerView
        self.view.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.snp.bottom)
        }

        // prepare ttplayer
        setupEngine()
        let source = TTVideoEngineUrlSource(url: videoUrl, cacheKey: videoUrl.md5(), videoId: videoUrl.md5())
        engine.ls_setDirectURLSource(source)
        engine.prepareToPlay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        engine.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        engine.pause()
    }
    
    private func setupEngine() {
        engine.setOptionForKey(VEKKey.VEKKeyPlayerHLSSeamlessSwitchEnable_BOOL.rawValue, value: true)
        engine.setOptionForKey(VEKKey.VEKKeyMasterm3u8OptimizeEnable_BOOL.rawValue, value: true)

        engine.setOptionForKey(VEKKey.VEKKeyViewScaleMode_ENUM.rawValue, value: TTVideoEngineScalingMode.aspectFit.rawValue)

        // decrypt play needed
        
        engine.setOptionForKey(VEKKey.VEKKeyPlayerSetPrivateFFmpegProto_NSString.rawValue, value: "demo")
        // fixed 21
        engine.setOptionForKey(VEKKey.VEKKeyPlayerSetHLSConvertUrlOrder_NSString.rawValue, value: "21")
        // enabled buffer processor
        engine.setOptionForKey(VEKKey.VEKKeyIsAllowBufferProcessProtoNameSI.rawValue, value: NSNumber(value: 1))
        // setup buffer delegate
        engine.bufferProcessorDelegate = self
    }
    
    private var processorDict: [String: DRMProcessor] = [:]
}

extension TTPlayerViewController: TTVideoEngineBufferProcessorDelegate {
    private enum ErrorRet: Int32 {
        case nilParam = -10001
        case noProcessor = -10002
    }
            
    private func createPlugin() -> DRMPlugin {
        let plugin = DRMPlugin()
        return plugin
    }
    
    func opened(_ url: String!, result ret: Int) {
        guard let url else { return }
        
        let plugin = createPlugin()
        let processor = DRMProcessor(plugin: plugin)
        processorDict[url] = processor
    }
    
    func readed(_ url: String!, result ret: Int) {
        guard let url else { return }
        
        if ret == 0 {
            // all data read
            processorDict[url]?.setAllDataRead()
        }
    }
    
    func closed(_ url: String!, result ret: Int) {
        guard let url else { return }
        processorDict[url] = nil
    }
    
    func isChuck(_ url: String!) -> Int32 {
        guard let url else { return 0 }

        return 1
    }
    
    func prcocess(_ url: String!, intput intputData: Data!) -> TTVideoEngineBufferProcessResult! {
        guard let url, let intputData else {
            fatalError("get an nil url or data from tt sdk")
        }
        
        guard let processor = processorDict[url] else {
            fatalError("get an nil url from tt sdk")
        }
        return processor.process(url: url, input: intputData)
    }
}


private class DRMProcessor {
    var plugin: DRMPlugin
    private var allRead: Bool = false // all input data read
    private var allProcessed: Bool = false // all data processed
    
    init(plugin: DRMPlugin) {
        self.plugin = plugin
    }
    
    func setAllDataRead() {
        self.allRead = true
    }
    
    func process(url: String, input: Data) -> TTVideoEngineBufferProcessResult {
        let processResult = TTVideoEngineBufferProcessResult()
        if allRead, allProcessed {
            // all data process finished
            processResult.ret = 0
            return processResult
        }
        
        let dataResult = plugin.process(url: url, data: input)
        switch dataResult {
        case .success(let success):
            processResult.resultData = success
            if allRead {
                allProcessed = true
            }
        case .failure(let failure):
            if case .requireMoreData = failure {
                processResult.ret = -EAGAIN
            } else {
                processResult.ret = -1000
                print("process fail \(failure)")
            }
        }
        return processResult
    }
}
