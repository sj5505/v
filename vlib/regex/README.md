# V RegEx (Regular expression) 0.9c 

[TOC]

## introduction

Write here the introduction

## Basic assumption

In this release, during the writing of the code some assumption are made and are valid for all the features.

1. The matching stops at the end of the string not at the newline chars.
2. The basic element of this regex engine are the tokens, in query string a simple char is a token. The token is the atomic unit of this regex engine.

## Match positional limiter

The module supports the following features:

- `$` `^` delimiter

`^` (Caret.) Matches at the start of the string

`?` Matches at the end of the string

## Tokens

The tokens are the atomic unit used by this regex engine and can be ones of the following:

### Simple char

this token is a simple single character like `a`.

### Char class (cc)

The cc match all the chars specified in its inside, it is delimited by square brackets `[ ]`

the sequence of chars in the class is evaluated with an OR operation.

For example the following cc `[abc]` match any char that is `a` or `b` or `c` but doesn't match `C` or `z`.

Inside a cc is possible to specify a "range" of chars, for example `[ad-f]` is equivalent to write `[adef]`. 

A cc can have different ranges at the same time like `[a-zA-z0-9]` that match all the lowercase,uppercase and numeric chars.

It is possible negate the cc using the caret char at the start of the cc like: `[^abc]` that matches every char that is not `a` or `b` or `c`.

A cc can contain meta-chars like: `[a-z\d]` that matches all the lowercase latin chars `a-z` and all the digits `\d`.

It is possible to mix all the properties of the char class together.

### Meta-chars

A meta-char is specified by a backslash before a char like `\w` in this case the meta-char is `w`.

A meta-char can match different type of chars.

* `\w` match an alphanumeric char `[a-zA-Z0-9]`
* `\W` match a non alphanumeric char
* `\d` match a digit `[0-9]`
* `\D` match a non digit
* `\s`match a space char, one of `[' ','\t','\n','\r','\v','\f']`
* `\S` match a non space char
* `\a` match only a lowercase char `[a-z]` 
* `\A` match only an uppercase char `[A-Z]`

### Quantifier

Each token can have a quantifier that specify how many times the char can or must be matched.

**Short quantifier**

- `?` match 0 or 1 time, `a?b` match both `ab` or `b`
- `+` match at minimum 1 time, `a+` match both `aaa` or `a`
- `*` match 0 or more time, `a*b` match both `aaab` or `ab` or `b`

**Long quantifier**

- `{x}` match exactly x time, `a{2}` match `aa` but doesn't match `aaa` or `a`
- `{min,}` match at minimum min time, `a{2,}` match `aaa` or `aa` but doesn't match `a`
- `{,max}` match at least 1 time and maximum max time, `a{,2}` match `a` and `aa` but doesn't match `aaa`
- `{min,max}` match from min times to max times, `a{2,3}` match `aa` and `aaa` but doesn't match `a` or `aaaa`

a long quantifier may have a `greedy off` flag that is the `?` char after the brackets, `{2,4}?` means to match the minimum number possible tokens in this case 2.

### dot char

the dot is a particular meta char that match  "any char", is more simple explain it with an example:

suppose to have `abccc ddeef` as source string to parse with regex, the following table show the query strings and the result of parsing source string.

| query string | result |
| ------------ | ------ |
| `.*c`        | `abc`  |
|  `.*dd`		 |  `abcc dd` |
| `ab.*e` | `abccc dde` |
| `ab.{3} .*e` | `abccc dde` |

the dot char match any char until the next token match is satisfied.

### OR token

the token `|` is a logic OR operation between two consecutive tokens, `a|b` match a char that is `a` or `b`.

The or token can work in a "chained way": `a|(b)|cd ` test first `a` if the char is not `a` the test the group `(b)` and if the group doesn't match test the token `c`.

**note: The OR work at token level! It doesn't work at concatenation level!**

A query string like `abc|bde` is not equal to `(abc)|(bde)`!!  The OR work only on `c|b` not at char concatenation level.

### Groups

Groups are a method to create complex patterns with repetition of blocks of tokens.

The groups are delimited by round brackets `( )`, groups can be nested and can have a quantifier as all the tokens.

`c(pa)+z` match `cpapaz` or `cpaz` or `cpapapaz` .

`(c(pa)+z ?)+` match `cpaz cpapaz cpapapaz` or `cpapaz` 

let analyze this last case, first we have the group `#0` that are the most outer round brackets `(...)+`, this group has a quantifier that say to match its content at least one time `+`. 

After we have a simple char token `c` and a second group that is the number `#1` :`(pa)+`, this group try to match the sequence `pa` at least one time as specified by the `+` quantifier.

After, we have another simple token `z` and another simple token ` ?` that is the space char (ascii code 32) followed by the `?` quantifier that say to capture the space char 0 or 1 time.

This explain because the `(c(pa)+z ?)+` query string can match `cpaz cpapaz cpapapaz` .

In this implementation the groups are "capture groups", it means that the last temporal result for each group can be retrieved from the `RE` struct.

The "capture groups" are store as couple of index in the field `groups` that is an `[]int` inside the `RE` struct. 

**example:**

```v
text := "cpaz cpapaz cpapapaz"
query:= r"(c(pa)+z ?)+"
re, _, _ := regex.regex(query) 

println(re.get_query())
// #0(c#1(pa)+z ?)+  // #0 and #1 are the ids of the groups, are shown if re.debug is 1 or 2

start, end := re.match_string(text)
// [start=0, end=20]  match => [cpaz cpapaz cpapapaz]

mut gi := 0
for gi < re.groups.len {
	if re.groups[gi] >= 0 {
		println("${gi/2} :[${text[re.groups[gi]..re.groups[gi+1]]}]")
	}
	gi += 2
}
// groups captured
// 0 :[cpapapaz]
// 1 :[pa]


```

**note:** *to show the `group id number` in the result of the `get_query()` the flag `debug` of the RE object must be `1` or `2`*

## Flags

It is possible to set some flags in the regex parser that change the behavior of the parser itself.

```v
// example of flag settings
mut re := regex.new_regex()
re.flag = regex.F_BIN 

```

- `F_BIN`: parse a string as bytes, utf-8 management disabled.

- `F_EFM`: exit on the first char match in the query, used by the find function.
- `F_MS`: match only if the index of the start match is 0, same as `^` at the start of the query string.
- `F_ME`: match only if the end index of the match is the last char of the input string, same as `$` end of query string.
- `F_NL`: stop the matching if found a new line char `\n` or `\r`

## Functions

### Initializer

These function are helper that create the `RE` struct, a `RE` struct can be created manually if you needed.

**Simplified initializer**

```v
// regex create a regex object from the query string and compile it
pub fn regex(in_query string) (RE,int,int)
```

**Base initializer**

```v
// new_regex create a REgex of small size, usually sufficient for ordinary use
pub fn new_regex() RE

// new_regex_by_size create a REgex of large size, mult specify the scale factor of the memory that will be allocated
pub fn new_regex_by_size(mult int) RE
```
After the base initializer use, the regex expression must be compiled with:
```v
// compile return (return code, index) where index is the index of the error in the query string if return code is an error code
pub fn (re mut RE) compile(in_txt string) (int,int)
```

### Functions

These are the operative functions

```v
// match_string try to match the input string, return start and end index if found else start is -1
pub fn (re mut RE) match_string(in_txt string) (int,int)

// find try to find the first match in the input string, return start and end index if found else start is -1
pub fn (re mut RE) find(in_txt string) (int,int)

// find_all find all the "non overlapping" occurrences of the matching pattern, return a list of start end indexes
pub fn (re mut RE) find_all(in_txt string) []int

// replace return a string where the matches are replaced with the replace string, only non overlapped matches are used
pub fn (re mut RE) replace(in_txt string, repl string) string
```

## Debugging

This module has few small utilities to help the writing of regex expressions.

**Syntax errors highlight**

the following example code show how to visualize the syntax errors in the compilation phase:

```v
query:= r"ciao da ab[ab-]"  // there is an error, a range not closed!!
mut re := new_regex()

// re_err ==> is the return value, if < 0 it is an error
// re_pos ==> if re_err < 0, re_pos is the error index in the query string 
re_err, err_pos := re.compile(query)

// print the error if one happen
if re_err != COMPILE_OK {
	println("query: $query")
    lc := "-".repeat(err_pos)
    println("err  : $lc^")
    err_str := re.get_parse_error_string(re_err)  // get the error string
    println("ERROR: $err_str")
}

// output!!

//query: ciao da ab[ab-]
//err  : ----------^
//ERROR: ERR_SYNTAX_ERROR

```

**Compiled code**

It is possible view the compiled code calling the function `get_query()` the result will be something like this:

```
========================================
v RegEx compiler v 0.9c output:
PC:  0 ist: 7fffffff [a]      query_ch {  1,  1}
PC:  1 ist: 7fffffff [b]      query_ch {  1,MAX}
PC:  2 ist: 88000000 PROG_END {  0,  0}
========================================
```

`PC`:`int` is the program counter or step of execution, each single step is a token.

`ist`:`hex` is the token instruction id.

`[a]` is the char used by the token.

`query_ch` is the type of token.

`{m,n}` is the quantifier, the greedy off flag  `?`  will be showed if present in the token

**Log debug**

The log debugger allow to print the status of the regex parser when the parser is running.

It is possible to have two different level of debug: 1 is normal while 2 is verbose.

here an example:

*normal*

list only the token instruction with their values

```
// re.flag = 1 // log level normal
flags: 00000000
#   2 s:     ist_load PC:   0=>7fffffff i,ch,len:[  0,'a',1] f.m:[ -1, -1] query_ch: [a]{1,1}:0 (#-1)
#   5 s:     ist_load PC:   1=>7fffffff i,ch,len:[  1,'b',1] f.m:[  0,  0] query_ch: [b]{2,3}:0? (#-1)
#   7 s:     ist_load PC:   1=>7fffffff i,ch,len:[  2,'b',1] f.m:[  0,  1] query_ch: [b]{2,3}:1? (#-1)
#  10 PROG_END
```

*verbose*

list all the instructions and states of the parser

```
flags: 00000000
#   0 s:        start PC: NA
#   1 s:     ist_next PC: NA
#   2 s:     ist_load PC:   0=>7fffffff i,ch,len:[  0,'a',1] f.m:[ -1, -1] query_ch: [a]{1,1}:0 (#-1)
#   3 s:  ist_quant_p PC:   0=>7fffffff i,ch,len:[  1,'b',1] f.m:[  0,  0] query_ch: [a]{1,1}:1 (#-1)
#   4 s:     ist_next PC: NA
#   5 s:     ist_load PC:   1=>7fffffff i,ch,len:[  1,'b',1] f.m:[  0,  0] query_ch: [b]{2,3}:0? (#-1)
#   6 s:  ist_quant_p PC:   1=>7fffffff i,ch,len:[  2,'b',1] f.m:[  0,  1] query_ch: [b]{2,3}:1? (#-1)
#   7 s:     ist_load PC:   1=>7fffffff i,ch,len:[  2,'b',1] f.m:[  0,  1] query_ch: [b]{2,3}:1? (#-1)
#   8 s:  ist_quant_p PC:   1=>7fffffff i,ch,len:[  3,'b',1] f.m:[  0,  2] query_ch: [b]{2,3}:2? (#-1)
#   9 s:     ist_next PC: NA
#  10 PROG_END
#  11 PROG_END
```

the columns have the following meaning:

`#   2` number of actual steps from the start of parsing

`s:     ist_next` state of the present step

`PC:   1` program counter of the step

`=>7fffffff ` hex code of the instruction 

`i,ch,len:[  0,'a',1]` `i` index in the source string, `ch` the char parsed, `len` the length in byte of the char parsed

`f.m:[  0,  1]` `f` index of the first match in the source string, `m` index that is actual matching

`query_ch: [b]` token in use and its char

`{2,3}:1?` quantifier `{min,max}`, `:1` is the actual counter of repetition, `?` is the greedy off flag if present

## Example code

Here there is a simple code to perform some basically match of strings

```v
struct TestObj {
	source string // source string to parse
	query  string // regex query string
	s int         // expected match start index
	e int         // expected match end index
}
const (
tests = [
	TestObj{"this is a good.",r"this (\w+) a",0,9},
	TestObj{"this,these,those. over",r"(th[eio]se?[,. ])+",0,17},
	TestObj{"test1@post.pip.com, pera",r"[\w]+@([\w]+\.)+\w+",0,18},
	TestObj{"cpapaz ole. pippo,",r".*c.+ole.*pi",0,14},
	TestObj{"adce aabe",r"(a(ab)+)|(a(dc)+)e",0,4},
]
)

fn example() {
	for c,tst in tests {
		mut re := regex.new_regex()
		re_err, err_pos := re.compile(tst.query)
		if re_err == regex.COMPILE_OK {
			
			// print the query parsed with the groups ids
			re.debug = 1 // set debug on at minimum level
			println("#${c:2d} query parsed: ${re.get_query()}")
			re.debug = 0
			
			// do the match
			start, end := re.match_string(tst.source)
			if start >= 0 && end > start {
				println("#${c:2d} found in: [$start, $end] => [${tst.source[start..end]}]")
			}	
			
			// print the groups
			mut gi := 0
			for gi < re.groups.len {
				if re.groups[gi] >= 0 {
					println("group ${gi/2:2d} :[${tst.source[re.groups[gi]..re.groups[gi+1]]}]")
				}
				gi += 2
			}		
			println("")
		} else {
			// print the compile error
			println("query: $tst.query")
			lc := "-".repeat(err_pos-1)
			println("err  : $lc^")
			err_str := re.get_parse_error_string(re_err)
			println("ERROR: $err_str")
		}
	}
}

fn main() {
	example()
}
```

more example code is available in the test code for the `regex` module `vlib\regex\regex_test.v`.

