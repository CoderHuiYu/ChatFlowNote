// Copyright © 2017 Tellus, Inc. All rights reserved.

protocol JSONValue { }

extension Bool : JSONValue { }
extension Int : JSONValue { }
extension Double : JSONValue { }
extension String : JSONValue { }
extension Array : JSONValue { }
extension Dictionary : JSONValue { }
extension NSNull : JSONValue { }
