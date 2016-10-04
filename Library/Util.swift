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

class Util
{
    class func randomInt(_ max: Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(max)))
    }

    class func randomDouble(_ max: Int = 1) -> Double
    {
        return Double(randomInt(max * 100_000)) / Double(100_000)
    }

    class func sizeofArray<T>(_ array: [T]) -> Int
    {
        return array.count * MemoryLayout<T>.size
    }

    class func enumForCode<E: RawRepresentable>(_ code :Int, defaultCase: E) -> E where E.RawValue == Int
    {
        let val: Int
        if code == -1 {
            var maxValue: Int = 0
            while let _ = E(rawValue: maxValue) {
                maxValue += 1
            }
            val = Util.randomInt(maxValue)
        } else {
            val = code
        }
        return E(rawValue: val) ?? defaultCase
    }
    
}



