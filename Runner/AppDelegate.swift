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

@NSApplicationMain
class AppDelegate: NSObject
{
    @IBOutlet weak var window: NSWindow!

    var view: ScreenSaverView!

    func setupAndStartAnimation()
    {
        // change class below to select which saver to run
        view = DancingGlyphsView(frame: window.contentView!.frame, isPreview: false)
        view.autoresizingMask = [NSAutoresizingMaskOptions.viewWidthSizable, NSAutoresizingMaskOptions.viewHeightSizable]
        window.contentView!.autoresizesSubviews = true
        window.contentView!.addSubview(view)
        window.backingType = MetalScreenSaverView.backingStoreType()
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
        view.stopAnimation()
        view.startAnimation()
    }
}
