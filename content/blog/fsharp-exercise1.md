+++
date = "2016-08-01"
draft = false

categories = ["blog"]

title = "F# Exercise: split a sequence of lot/plans"
description = "An F# exercise of expanding a string representation of multiple numbers to individual numbers, e.g. [36-39,41,42] to [36,37,38,39,41,42]"
+++

This problem came up at work. Client would like to search for multiple lot plans, we want to allow them to enter multiple lots using a shorthand.

A lot/plan follows this format: `234/RP12345`<br />
The short hand for `234/RP12345 & 235/RP12345` is either of: 

- `234,235/RP12345`
- `234-235/RP12345`

Now lets say a property developer wants to search for these properties all at once:<br />
![alt text](/images/LotPlanSplitExample.png "Example of a group of Lot/Plans")

<sup>[Screenshot taken from http://eatlas.org.au](http://eatlas.org.au/content/qld-dnrm-property-boundaries)</sup>

The property developer would enter `36-39,41,42/RP711798`<br />
And they'd expect the following lots: `36,37,38,39,41,42`

Here's my solution using F#:
``` fsharp
open System.Text.RegularExpressions

let (|RegexMatch|_|) pattern input =
    let m = Regex.Match(input, pattern) 
    if (m.Success) then Some input else None

let parseRange (rangeStr: string) =
    let rangeSplit = rangeStr.Split('-')
    let range = [rangeSplit.[0] |> int .. rangeSplit.[1] |> int]
    range

let parseStr (part: string) =
    match part with
    | RegexMatch @"^\d+$" x -> [x |> int]
    | RegexMatch @"^(\d+)-(\d+)$" x -> parseRange x
    | x -> failwith ("unknown part: " + x)

let rec splitNumbers (numbers: string list) =
    match numbers with
    | [] -> []
    | head::tail -> parseStr head @ splitNumbers tail

let splitLots x = 
    x.Replace(" ", "").Split(',') |> Seq.toList |> splitNumbers

splitLots "1,2,5-7,10-12"
//val it : int list = [36; 37; 38; 39; 41; 42]
```

Here's my C# implementation:
``` cs
void Main()
{
	var x = "1,2,5-7";
	SplitLots(x).Dump();
}

int[] SplitLots(string lots)
{
	var parts = lots.Replace(" ", "").Split(',');
    return parts.SelectMany(x =>
	{
		if (Regex.Match(x, @"^\d+$").Success) return new[] { int.Parse(x) };
		if (Regex.Match(x, @"^(\d+)-(\d+)$").Success) return ParseStr(x);
		else throw new Exception($"unknown part: $x");
	}).ToArray();
}

int[] ParseStr(string lots) 
{
	var splitLots = lots.Split('-');
	var start = int.Parse(splitLots[0]);
	var end = int.Parse(splitLots[1]);
	return Enumerable.Range(start, end - start + 1).ToArray();
}
```

I'm a little disappointed my F# solution consisted of more code. To my defence, I developed the F# solution first, so the C# solution turned out very similar, but with shortcuts, also I'm primarily a C# developer. 

I'd be interested to see how others approached this problem, so feel free to post your solution in the comments below (or a link to your Gist).