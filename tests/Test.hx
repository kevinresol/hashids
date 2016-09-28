package;

import hashids.Hashids;
import haxe.unit.TestRunner;
import haxe.unit.TestCase;

#if flash
import flash.system.System.exit;
#else
import Sys.exit;
#end

class Test extends TestCase
{
	static function main()
	{
		var t = new TestRunner();
		t.add(new Test());
		
		exit(t.run() ? 0 : 500);
	}
	
	function testBasic()
	{
		var num_to_hash = 900719925;
		var	a = new Hashids("this is my salt");
		var res = a.encode(num_to_hash);
		var b = a.decode(res);
		assertEquals(num_to_hash, b[0]);
	}
	
	function testWrongDecoding()
	{
		var a = new Hashids("this is my pepper");
		var b = a.decode("NkK9");
		assertEquals(0, b.length);
	}

	function testOneNumber()
	{
		var expected = "NkK9";
		var num_to_hash = 12345;
		var a = new Hashids("this is my salt");
		
		var res = a.encode(num_to_hash);
		assertEquals(expected, res);
		
		var res2 = a.decode(expected);
		assertEquals(1, res2.length);
		assertEquals(num_to_hash, res2[0]);
		assertEquals(num_to_hash, res2); // test the abstract cast
	}

	function testServeralNumbers()
	{
		var expected = "aBMswoO2UB3Sj";
		var num_to_hash = [683, 94108, 123, 5];
		var a = new Hashids("this is my salt");
		
		var res = a.encode(num_to_hash);
		assertEquals(expected, res);
		
		var res2 = a.decode(expected);
		assertEquals(num_to_hash.length, res2.length);
		for(i in 0...res.length)
			assertEquals(num_to_hash[i], res2[i]);
	}

	function testSpecifyingCustomHashAlphabet()
	{
		var expected = "b332db5";
		var num_to_hash = 1234567;
		var a = new Hashids("this is my salt", 0, "0123456789abcdef");
		
		var res = a.encode(num_to_hash);
		assertEquals(expected, res);
		
		var res2 = a.decode(expected);
		assertEquals(num_to_hash, res2[0]);
		assertEquals(num_to_hash, res2); // test the abstract cast
	}

	function testSpecifyingCustomHashLength()
	{
		var expected = "gB0NV05e";
		var num_to_hash = 1;
		var a = new Hashids("this is my salt", 8);
		
		var res = a.encode(num_to_hash);
		assertEquals(expected, res);
		
		var res2 = a.decode(expected);
		assertEquals(1, res2.length);
		assertEquals(num_to_hash, res2[0]);
		assertEquals(num_to_hash, res2); // test the abstract cast
	}

	function testRandomness()
	{
		var expected = "1Wc8cwcE", res;
		var num_to_hash = [5, 5, 5, 5];
		var a = new Hashids("this is my salt");
		
		var res = a.encode(num_to_hash);
		assertEquals(expected, res);
		
		var res2 = a.decode(expected);
		assertEquals(num_to_hash.length, res2.length);
		for(i in 0...res.length)
			assertEquals(num_to_hash[i], res2[i]);
	}

	function testRandomnessForIncrementingNumbers()
	{
		var expected = "kRHnurhptKcjIDTWC3sx";
		var num_to_hash = [1,2,3,4,5,6,7,8,9,10];
		var a = new Hashids("this is my salt");
		
		var res = a.encode(num_to_hash);
		assertEquals(expected, res);
		
		var res2 = a.decode(expected);
		assertEquals(res2.length, num_to_hash.length);
		for(i in 0...res.length)
			assertEquals(num_to_hash[i], res2[i]);
	}

	function testRandomnessForIncrementing()
	{
		var a = new Hashids("this is my salt");
		assertEquals("NV", a.encode(1));
		assertEquals("6m", a.encode(2));
		assertEquals("yD", a.encode(3));
		assertEquals("2l", a.encode(4));
		assertEquals("rD", a.encode(5));
	}

	function testAlphabetWithoutO0()
	{
		var expected = "9Q7MJ3LVGW";
		var num_to_hash = 1145;
		var a = new Hashids("MyCamelCaseSalt", 10, "ABCDEFGHIJKLMNPQRSTUVWXYZ123456789");
		
		var res = a.encode(num_to_hash);
		assertEquals(expected, res);
		
		var res2 = a.decode(expected);
		assertEquals(num_to_hash, res2[0]);
		assertEquals(num_to_hash, res2); // test the abstract cast
	}
}

