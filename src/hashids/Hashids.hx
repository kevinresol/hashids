package hashids;

using StringTools;

class Hashids
{
	static inline var DEFAULT_ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
	static inline var MIN_ALPHABET_LENGTH = 16;
	static inline var SEP_DEV = 3.5;
	
	var salt:String = "";
	var alphabet:String = "";
	var seps:String = "cfhistuCFHISTU";
	var minHashLength:Int = 0;
	var guards:String;
	
	public function new(salt:String = "", minHashLength:Int = 0, alphabet:String = DEFAULT_ALPHABET)
	{
		this.salt = salt;
		this.minHashLength = minHashLength < 0 ? 0 : minHashLength;
		
		var uniqueAlphabet = "";
		for(i in 0...alphabet.length)
		{
			var c = alphabet.charAt(i);
			if(uniqueAlphabet.indexOf(c) < 0)
				uniqueAlphabet += c;
		}
		
		alphabet = uniqueAlphabet;
		
		var minAlphabetLength = 16;
		if(alphabet.length < MIN_ALPHABET_LENGTH)
			throw 'Alphabet must contain at least $MIN_ALPHABET_LENGTH unique characters.';
		
		if(alphabet.indexOf(" ") >= 0)
			throw "Alphabet cannot contains spaces.";
		
		// seps should contain only characters present in alphabet;
		// alphabet should not contains seps
		for(i in 0...seps.length)
		{
			var j = alphabet.indexOf(seps.charAt(i));
			if(j == -1)
				seps = seps.substring(0, i) + " " + seps.substring(i + 1);
			else
				alphabet = alphabet.substring(0, j) + " " + alphabet.substring(j + 1);
		}
		
		var whiteSpacesReg = ~/\s+/g;
		alphabet = whiteSpacesReg.replace(alphabet, "");
		seps = whiteSpacesReg.replace(seps, "");
		seps = consistentShuffle(seps, salt);
		
		
		
		if(seps == "" || alphabet.length / seps.length > SEP_DEV)
		{
			var seps_len = Math.ceil(alphabet.length / SEP_DEV);
			
			if(seps_len == 1)
				seps_len++;
			
			if(seps_len > seps.length)
			{
				var diff = seps_len - seps.length;
				seps += alphabet.substring(0, diff);
				alphabet = alphabet.substring(diff);
			}
			else
				seps = seps.substring(0, seps_len);
		}
		
		alphabet = consistentShuffle(alphabet, salt);
		
		var guardDiv = 12;
		var guardCount = Math.ceil(alphabet.length / guardDiv);
		
		if(alphabet.length < 3)
		{
			guards = seps.substring(0, guardCount);
			seps = seps.substring(guardCount);
		}
		else
		{
			guards = alphabet.substring(0, guardCount);
			alphabet = alphabet.substring(guardCount);
		}
		
		this.alphabet = alphabet;
	}
	
	/**
	 * Encode numbers to string
	 *
	 * @param numbers Numbers to encode
	 * @return Encoded string
	 */
	public function encode(?number:Int, ?numbers:Array<Int>):String
	{
		if(number == null && numbers == null) throw "Please provide a number or an array of numbers";
		
		if(numbers == null) numbers = [];
		if(number != null) numbers.unshift(number);
		
		// for (number in numbers)
		// {
		// 	if (number > Math.MAX_VALUE)
		// 		throw "Number can not be greater than " + Number.MAX_VALUE;
		// }
		
		if(numbers.length == 0)
			return "";
		
		return _encode(numbers);
	}
	
	/**
	 * Decode string to numbers
	 *
	 * @param hash Encoded string
	 * @return Decoded numbers
	 */
	public function decode(hash:String):Array<Int>
	{
		if(hash == "")
			return [];
		
		return _decode(hash, alphabet);
	}

	function _encode(numbers:Array<Int>):String
	{
		var numberHashInt = 0;
		for(i in 0...numbers.length)
			numberHashInt += (numbers[i] % (i+100));
		
		var alphabet = this.alphabet;
		var ret = alphabet.split("")[numberHashInt % alphabet.length];
		var num;
		var sepsIndex;
		var guardIndex;
		var buffer;
		var ret_str = ret + "";
		var guard;
		
		for(i in 0...numbers.length)
		{
			num = numbers[i];
			buffer = ret + salt + alphabet;
			
			alphabet = consistentShuffle(alphabet, buffer.substring(0, alphabet.length));
			var last = hash(num, alphabet);
			
			ret_str += last;
			
			if(i+1 < numbers.length)
			{
				num %= (last.charCodeAt(0) + i);
				sepsIndex = num % seps.length;
				ret_str += seps.split("")[sepsIndex];
			}
		}
		
		if(ret_str.length < minHashLength)
		{
			guardIndex = (numberHashInt + ret_str.charCodeAt(0)) % guards.length;
			guard = guards.split("")[guardIndex];
			
			ret_str = guard + ret_str;
			
			if(ret_str.length < minHashLength)
			{
				guardIndex = (numberHashInt + ret_str.charCodeAt(2)) % guards.length;
				guard = guards.split("")[guardIndex];
				
				ret_str += guard;
			}
		}
		
		while(ret_str.length < minHashLength)
		{
			var halfLen = Std.int(alphabet.length / 2);
			alphabet = consistentShuffle(alphabet, alphabet);
			ret_str = alphabet.substring(halfLen) + ret_str + alphabet.substring(0, halfLen);
			
			var excess = ret_str.length - minHashLength;
			if(excess > 0)
			{
				var start_pos = Std.int(excess / 2);
				ret_str = ret_str.substring(start_pos, start_pos + minHashLength);
			}
		}
		
		return ret_str;
	}
	
	function _decode(hash:String, alphabet:String):Array<Int>
	{
		var ret = [];
		
		var i = 0;
		var regexp = new EReg('[$guards]', "g");
		var hashBreakdown = regexp.replace(hash, " ");
		var hashArray = hashBreakdown.split(" ");
		
		if(hashArray.length == 3 || hashArray.length == 2)
			i = 1;
		
		hashBreakdown = hashArray[i];
		
		var lottery = hashBreakdown.split("")[0];
		
		hashBreakdown = hashBreakdown.substring(1);
		hashBreakdown = new EReg('[$seps]', "g").replace(hashBreakdown, " ");
		hashArray = hashBreakdown.split(" ");
		
		var subHash;
		var buffer;
		for (aHashArray in hashArray)
		{
			subHash = aHashArray;
			buffer = lottery + salt + alphabet;
			alphabet = consistentShuffle(alphabet, buffer.substring(0, alphabet.length));
			ret.push(unhash(subHash, alphabet));
		}
		
		if(!(_encode(ret) == hash))
			ret = [];
		
		return ret;
	}
	
	function consistentShuffle(alphabet:String, salt:String):String
	{
		if(salt.length <= 0)
			return alphabet;
		
		var arr = salt.split("");
		var i = alphabet.length - 1;
		var v = 0;
		var p = 0;
		while(i > 0)
		{
			v %= salt.length;
			var asc_val = arr[v].charCodeAt(0);
			p += asc_val;
			var j = (asc_val + v + p) % i;
			
			var tmp = alphabet.charAt(j);
			alphabet = alphabet.substring(0, j) + alphabet.charAt(i) + alphabet.substring(j + 1);
			alphabet = alphabet.substring(0, i) + tmp + alphabet.substring(i + 1);
			
			i--;
			v++;
		}
		
		return alphabet;
	}
	
	function hash(input:Int, alphabet:String):String
	{
		var hash = "";
		var alphabetLen = alphabet.length;
		var arr = alphabet.split("");
		
		do
		{
			hash = arr[input % alphabetLen] + hash;
			input = Math.floor(input / alphabetLen);
		}
		while(input > 0);
		
		return hash;
	}
	
	function unhash(input:String, alphabet:String):Int
	{
		var number = 0;
		var input_arr = input.split("");
		
		for(i in 0...input.length)
		{
			var pos = alphabet.indexOf(input_arr[i]);
			number += Std.int(pos * Math.pow(alphabet.length, input.length - i - 1));
		}
		
		return number;
	}

}