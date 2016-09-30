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

class Statistics
{
    private var lastCheckpoint: Double = 0
    private var frameStartTime: Double = 0
    private var renderTimeSinceCheckpoint: Double = 0
    private var framesSinceCheckpoint: Int = 0
    private var longestRenderTime: Double = 0
    
    func viewWillStartRenderingFrame()
    {
        frameStartTime = CACurrentMediaTime()
    }
    
    func viewDidFinishRenderingFrame()
    {
        let now = CACurrentMediaTime()
        let renderTime = (now - frameStartTime)
        longestRenderTime = max(longestRenderTime, renderTime)
        renderTimeSinceCheckpoint += renderTime
        framesSinceCheckpoint += 1

        if (now - lastCheckpoint) >= 1.0 {
#if DEBUG
            print()
#endif
            lastCheckpoint = now
            framesSinceCheckpoint = 0
            renderTimeSinceCheckpoint = 0
            longestRenderTime = 0
        }
    }
    
    fileprivate func print()
    {
        let text = String(format:"%d fps, render time (avg/max): %.2f/%.2f ms",
                framesSinceCheckpoint,
                renderTimeSinceCheckpoint / Double(framesSinceCheckpoint) * 1000,
                longestRenderTime * 1000)
        NSLog(text)
    }


}
