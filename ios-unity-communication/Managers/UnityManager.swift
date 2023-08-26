//
//  UnityManager.swift
//  ios-unity-communication
//
//  Created by Betül Çalık on 26.08.2023.
//

import Foundation
import UnityFramework

protocol UnityManagerDelegate: AnyObject {
    func didButtonPress(message: String)
}

final class UnityManager: UIResponder, UIApplicationDelegate {
    
    // MARK: - Variables
    static let shared = UnityManager()
    weak var delegate: UnityManagerDelegate?
    
    private let dataBundleId = "com.unity3d.framework"
    private let frameworkPath = "/Frameworks/UnityFramework.framework"
    
    private var unityFramework: UnityFramework?
    private var hostMainWindow: UIWindow?
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    private var isInitialized: Bool {
        return unityFramework != nil && unityFramework?.appController() != nil
    }
    
    // The structure for Unity messages
    private struct UnityMessage {
        let objectName: String?
        let methodName: String?
        let messageBody: String?
    }
    private var cachedMessages = [UnityMessage]()
    
    // MARK: - Public Functions
    func show() {
        if isInitialized {
            showUnityWindow()
            return
        }
        
        initUnityWindow()
    }
    
    func setHostMainWindow(_ hostMainWindow: UIWindow?) {
        self.hostMainWindow = hostMainWindow
    }
    
    func getUnityRootVC() -> UIViewController! {
        return unityFramework?.appController().rootViewController
    }
    
    /// Send Message to Unity
    func sendMessage(_ objectName: String, methodName: String, message: String) {
        let message: UnityMessage = UnityMessage(
            objectName: objectName,
            methodName: methodName,
            messageBody: message
        )
        
        if isInitialized {
            unityFramework?.sendMessageToGO(
                withName: message.objectName,
                functionName: message.methodName,
                message: message.messageBody
            )
        } else {
            cachedMessages.append(message)
        }
    }
    
    // MARK: - Private Functions
    private func initUnityWindow() {
        guard let unityFramework = loadUnityFramework() else {
            debugPrint("ERROR: Was not able to load Unity")
            return unloadUnityWindow()
        }
        
        self.unityFramework = unityFramework
        self.unityFramework?.setDataBundleId(dataBundleId)
        self.unityFramework?.register(self)
        self.unityFramework?.runEmbedded(withArgc: CommandLine.argc,
                                         argv: CommandLine.unsafeArgv,
                                         appLaunchOpts: launchOptions)
        NSClassFromString("FrameworkLibAPI")?.registerAPIforNativeCalls(self)
        sendCachedMessages()
    }
    
    private func showUnityWindow() {
        if isInitialized {
            unityFramework?.showUnityWindow()
            sendCachedMessages()
        }
    }
    
    private func unloadUnityWindow() {
        if isInitialized {
            cachedMessages.removeAll()
            unityFramework?.unloadApplication()
        }
    }
    
    private func loadUnityFramework() -> UnityFramework? {
        let bundlePath: String = Bundle.main.bundlePath + frameworkPath
        let bundle = Bundle(path: bundlePath)
        
        if bundle?.isLoaded == false {
            bundle?.load()
        }
        
        let unityFramework = bundle?.principalClass?.getInstance()
        if unityFramework?.appController() == nil {
            let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
            machineHeader.pointee = _mh_execute_header
            
            unityFramework?.setExecuteHeader(machineHeader)
        }
        
        return unityFramework
    }
    
    private func sendCachedMessages() {
        if cachedMessages.count >= 0 && isInitialized {
            for message in cachedMessages {
                unityFramework?.sendMessageToGO(
                    withName: message.objectName,
                    functionName: message.methodName,
                    message: message.messageBody
                )
            }
            
            cachedMessages.removeAll()
        }
    }
    
}

// MARK: - Unity Framework Listener
extension UnityManager: UnityFrameworkListener {
    
    func unityDidUnload(_ notification: Notification!) {
        unityFramework?.appController().rootViewController.dismiss(animated: true)
        unityFramework?.unregisterFrameworkListener(self)
        unityFramework = nil
        hostMainWindow?.makeKeyAndVisible()
    }
    
}

// MARK: - Native Calls Protocol
extension UnityManager: NativeCallsProtocol {
    
    /// Get Message from Unity
    public func sendMessage(toMobileApp message: String) {
        print(message)
        delegate?.didButtonPress(message: message)
    }
    
}
