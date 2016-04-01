# hashids ![travis](https://travis-ci.org/kevinresol/hashids.svg?branch=master)
Haxe implementation of hashids (http://hashids.org/)


Implementation ported from AS3 (https://github.com/jovanpn/hashids.as)
Tests ported from JAVA (https://github.com/jiecao-fm/hashids-java)

**Tested for the following targets:**
- Neko
- Python
- (Node)JS
- Flash
- Java
- C++
- C#
- PHP

# Install

```
haxelib install hashids
```

# Usage

```haxe
import hashids.Hashids;

var hashids = new Hashids("this is my salt");

var encoded = hashids.encode(1);
var number = hashids.decode(encoded)[0];
trace(number); // 1

var encoded = hashids.encode([1, 2, 3]);
var numbers = hashids.decode(encoded);
trace(numbers); // [1, 2, 3]

```