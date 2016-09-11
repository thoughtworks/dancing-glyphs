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

import Foundation

class Statistics
{
    private var lastCheckpoint: Double = 0
    private var frameStartTime: Double = 0
    private var renderTimeSinceCheckpoint: Double = 0
    private var framesSinceCheckpoint: Int = 0
    private var longestRenderTime: Double = 0
    private var suspectedDroppedFrames: Int = 0
    
    func viewWillStartRenderingFrame()
    {
        let now = NSDate().timeIntervalSinceReferenceDate
        if (now - frameStartTime) >= 0.017 { // 1.0/60.0 {
            suspectedDroppedFrames += 1
        }
        frameStartTime = now
    }
    
    func viewDidFinishRenderingFrame()
    {
        let now = NSDate().timeIntervalSinceReferenceDate
        framesSinceCheckpoint += 1
        let renderTime = (now - frameStartTime)
        longestRenderTime = max(longestRenderTime, renderTime)
        renderTimeSinceCheckpoint += renderTime

        if (now - lastCheckpoint) >= 1.0 {
            printStatistics()
            lastCheckpoint = now
            framesSinceCheckpoint = 0
            renderTimeSinceCheckpoint = 0
            longestRenderTime = 0
            suspectedDroppedFrames = 0
        }
    }
    
    func printStatistics()
    {
        let text = String(format:"%d fps,render time (avg/max): %.2f/%.2f ms, dropped frames: %d",
                framesSinceCheckpoint,
                renderTimeSinceCheckpoint / Double(framesSinceCheckpoint) * 1000,
                longestRenderTime * 1000,
                suspectedDroppedFrames)
        NSLog(text)
    }


}