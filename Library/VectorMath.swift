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

// inspired by https://github.com/nicklockwood/VectorMath


import Foundation

public typealias Scalar = Float

public struct Vector2
{
    public var x: Scalar
    public var y: Scalar
}


public struct Matrix2x2
{
    public var m11: Scalar
    public var m12: Scalar
    public var m21: Scalar
    public var m22: Scalar
}


extension Vector2
{
    public init(_ x: Scalar, _ y: Scalar)
    {
        self.init(x: x, y: y)
    }

    public init(_ v: [Scalar])
    {
        assert(v.count == 2, "array must contain 2 elements, contained \(v.count)")
        self.init(v[0], v[1])
    }

    public static func +(lhs: Vector2, rhs: Vector2) -> Vector2
    {
        return Vector2(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    public static func -(lhs: Vector2, rhs: Vector2) -> Vector2
    {
        return Vector2(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    public static func *(lhs: Vector2, rhs: Scalar) -> Vector2
    {
        return Vector2(lhs.x * rhs, lhs.y * rhs)
    }

    public static func *(lhs: Vector2, rhs: Vector2) -> Vector2
    {
        return Vector2(lhs.x * rhs.x, lhs.y * rhs.y)
    }

    public static func *(lhs: Vector2, rhs: Matrix2x2) -> Vector2
    {
        return Vector2(
            lhs.x * rhs.m11 + lhs.y * rhs.m21,
            lhs.x * rhs.m12 + lhs.y * rhs.m22)
    }
    
    public static func /(lhs: Vector2, rhs: Vector2) -> Vector2
    {
        return Vector2(lhs.x / rhs.x, lhs.y / rhs.y)
    }
    
    public static func /(lhs: Vector2, rhs: Scalar) -> Vector2
    {
        return Vector2(lhs.x / rhs, lhs.y / rhs)
    }
    
    public static func ==(lhs: Vector2, rhs: Vector2) -> Bool
    {
        return (lhs.x ~= rhs.x) && (lhs.y ~= rhs.y)
    }
    
    public var lengthSquared: Scalar
    {
        return x * x + y * y
    }

    public func normalized() -> Vector2
    {
        let lengthSquared = self.lengthSquared
        if lengthSquared ~= 0 || lengthSquared ~= 1 {
            return self
        }
        return self / sqrt(lengthSquared)
    }

}


extension Matrix2x2
{
    public init(_ m11: Scalar, _ m12: Scalar,
                _ m21: Scalar, _ m22: Scalar)
    {
        self.init(m11: m11, m12: m12, m21: m21, m22: m22)
    }

    public init(_ m: [Scalar])
    {
        assert(m.count == 4, "array must contain 4 elements, contained \(m.count)")
        self.init(m[0], m[1], m[2], m[3])
    }

    public init(rotation radians: Scalar)
    {
        let cs = cos(radians)
        let sn = sin(radians)
        self.init(cs, -sn,
                  sn,  cs)
    }


}
