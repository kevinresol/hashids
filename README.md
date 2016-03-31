# hashids ![travis](https://travis-ci.org/kevinresol/hashids.svg?branch=master)
Haxe implementation of hashids

# Usage

```haxe
var hashids = new Hashids("this is my salt");

var encoded = hashids.encode(1);
var number = hashids.decode(encoded)[0];
trace(number); // 1

var encoded = hashids.encode([1, 2, 3]);
var numbers = hashids.decode(encoded);
trace(numbers); // [1, 2, 3]

```