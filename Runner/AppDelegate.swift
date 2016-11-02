/*
 *  Copyright 2016 Erik Doernenburg
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License. You may obtain
 *  a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 */

import Cocoa
import ScreenSaver
import Metal

@NSApplicationMain
class AppDelegate: NSObject
{
    @IBOutlet weak var window: NSWindow!

    var view: ScreenSaverView!

    func setupAndStartAnimation()
    {
        let saverName = UserDefaults.standard.string(forKey: "saver") ?? "DancingGlyphs"
        guard let saverBundle = loadSaverBundle(saverName) else {
            NSLog("Can't find or load bundle for saver named \(saverName).")
            return
        }
        let saverClass = saverBundle.principalClass! as! ScreenSaverView.Type
        
        view = saverClass.init(frame: window.contentView!.frame, isPreview: false)
        view.autoresizingMask = [NSAutoresizingMaskOptions.viewWidthSizable, NSAutoresizingMaskOptions.viewHeightSizable]

        window.backingType = saverClass.backingStoreType()
        window.title = view.className
        window.contentView!.autoresizesSubviews = true
        window.contentView!.addSubview(view)

        view.startAnimation()
    }

    private func loadSaverBundle(_ name: String) -> Bundle?
    {
        let myBundle = Bundle(for: AppDelegate.self)
        let saverBundleURL = myBundle.bundleURL.deletingLastPathComponent().appendingPathComponent("\(name).saver", isDirectory: true)
        let saverBundle = Bundle(url: saverBundleURL)
        saverBundle?.load()
        return saverBundle
    }

    func restartAnimation()
    {
        if view.isAnimating {
            view.stopAnimation()
        }
        view.startAnimation()
    }

    @IBAction func showPreferences(_ sender: NSObject!)
    {
        window.beginSheet(view.configureSheet()!, completionHandler: nil)
    }

}


extension AppDelegate: NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        MTLCopyAllDevices() // so that Xcode knows we're running a Metal app...
        setupAndStartAnimation()
    }
}


extension AppDelegate: NSWindowDelegate
{
    func windowWillClose(_ notification: Notification)
    {
        NSApplication.shared().terminate(window)
    }

    func windowDidResize(_ notification: Notification)
    {
    }

    func windowDidEndSheet(_ notification: Notification)
    {
        restartAnimation()
    }
}
