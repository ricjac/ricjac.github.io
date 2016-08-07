+++
date = "2016-07-30"
draft = false

categories = ["blog"]

title = "F# Collections: Lists"
description = "F# collection series which focuses on F# Lists. Covers initialising, working and operating over lists."

tableOfContents = true 
+++

F# lists are immutable collections.

# Initialising

List of integers

``` fsharp
let x = [1;2;3]
//val x : int list = [1; 2; 3]
```

List of integers, with values separated by new lines

``` fsharp
let x = [ 1
    2
    3 ]
//val x : int list = [1; 2; 3]
```

From a range of integers

``` fsharp
let x = [1..3]
//val x : int list = [1; 2; 3]
```

Using a `for` loop

``` fsharp
let x = [for i in 1..3 -> i]
//val x : int list = [1; 2; 3]
```

## Empty lists

Creating an empty integer list

``` fsharp
let x = List.empty<int>
//val x : int list = []
```

Note: `List.Empty` is an F# module (Notice the upper case 'E' in Empty)

Creating a generic list. The F# type inference will work out what type is used.

``` fsharp
let y = []
//val y : 'a list
```

# Working with lists

For this next section, I thought it might be useful to display an image I found useful when visualising parts of a list. 

![alt text](/images/listmonster.png "List monster")
<sub><a href="http://learnyouahaskell.com/starting-out#an-intro-to-lists" target="_blank">Image courtesy of: Learn You a Haskell for Great Good</a></sub>

A list can have elements added to it using the **cons** operator `::`.
The cons operator allows adding new elements to the **Head** of the list only. 

``` fsharp
let x = [1..3]
//val x : int list = [1; 2; 3]

let y = 0 :: x
//val y : int list = [0; 1; 2; 3]
```

But you can't use cons to add elements to the tail
``` fsharp
let z = y :: 4
//error FS0001: This expression was expected to have type int list list    
//but here has type int    
```

In order to append elements to a list, the concatenate operator `@` should be used. Only another list of the same type can be concatenated. So our value must be in a new list. 
``` fsharp
let z = y @ [4]
//val z : int list = [0; 1; 2; 3; 4]
```

The concat operator can of course also be used on two list existing lists, which produces a new list which consists of the values from both lists.
``` fsharp
let x = [1..3]
let y = [4..6]
let z = x @ y
//val z : int list = [1; 2; 3; 4; 5; 6]
```

# Operating over lists

The List `isEmpty` can be used to determine if the list is.. 
``` fsharp
let x = []
List.isEmpty x 
//val it : bool = true
```

Determine the List length
``` fsharp
let x = [1..10]
x.Length
//val it : int = 10 
```

Get the value of an item in a List, using a zero based index
``` fsharp
let x = [1..10]
x.Item 1
//val it : int = 2
```

And more importantly, the functions you will use mostly, `head` and `tail`. Remember the catapillar (List monster).
``` fsharp
let x = [1..10]
x.Head
//val it : int = 1
x.Tail
//val it : int list = [2; 3; 4; 5; 6; 7; 8; 9; 10]
```
