//
//  Reset.swift
//  mas-cli
//
//  Created by Andrew Naylor on 14/09/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

struct ResetCommand: CommandType {
    typealias Options = ResetOptions
    let verb = "reset"
    let function = "Resets the Mac App Store"
    
    func run(options: Options) -> Result<(), MASError> {
        /*
        The "Reset Application" command in the Mac App Store debug menu performs
        the following steps
 
         - killall Dock
         - killall storeagent (storeagent no longer exists)
         - rm com.apple.appstore download directory
         - clear cookies (appears to be a no-op)
         
        As storeagent no longer exists we will implement a slight variant and kill all
        App Store-associated processes
         - storeaccountd
         - storeassetd
         - storedownloadd
         - storeinstalld
         - storelegacy
        */
        
        // Kill processes
        let killProcs = [
            "Dock",
            "storeaccountd",
            "storeassetd",
            "storedownloadd",
            "storeinstalld",
            "storelegacy",
        ]
        
        let kill = NSTask()
        let stdout = NSPipe()
        let stderr = NSPipe()
        
        kill.launchPath = "/usr/bin/killall"
        kill.arguments = killProcs
        kill.standardOutput = stdout
        kill.standardError = stderr
        
        kill.launch()
        kill.waitUntilExit()
        
        if kill.terminationStatus != 0 && options.debug {
            let output = stderr.fileHandleForReading.readDataToEndOfFile()
            print("==> killall  failed:\r\n\(String(data: output, encoding: NSUTF8StringEncoding)!)")
        }
        
        // Wipe Download Directory
        let directory = CKDownloadDirectory(nil)
        do {
            try NSFileManager.defaultManager().removeItemAtPath(directory)
        } catch {
            if options.debug {
                print("removeItemAtPath:\"\(directory)\" failed, \(error)")
            }
        }
        
        return .Success(())
    }
}

struct ResetOptions: OptionsType {
    let debug: Bool
    
    static func evaluate(m: CommandMode) -> Result<ResetOptions, CommandantError<MASError>> {
        return curry(ResetOptions.init)
            <*> m <| Switch(flag: nil, key: "debug", usage: "Enable debug mode")
    }
}
