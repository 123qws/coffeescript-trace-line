coffeescript-trace-line
==========================

Generate instrumented Javascript code that traces lines as they are run. Compiles .coffee files to .js file, and adds ide.trace event (both for entering lines, enter and exit function). Inspired by [Benbria CoffeeCoverage](https://github.com/benbria/coffee-coverage).

Quick Demo
-------------------
After downloading all files, just run:	

	coffee coffee-trace-line.coffee example.coffee > example.js

You can check example.js. It adds some instrumented javascript code before every line of execution, the first line and the last line of function body.

After adding some fake "ide" object and run the javascript file, you will get all the execution event.

	{ line: 2, column: 0, type: '' }
	{ line: 3, column: 0, type: '' }
	{ line: 4, column: 0, type: '' }
	{ line: 4, column: 0, type: '' }
	{ line: 7, column: 0, type: '' }
	{ line: 8, column: 0, type: '' }
	{ line: 10, column: 23, type: '' }
	{ line: 14, column: 0, type: '' }
	{ line: 15, column: 0, type: '' }
	{ line: 16, column: 0, type: '' }
	{ line: 20, column: 0, type: '' }
	{ line: 20, column: 9, type: '' }
	{ line: 20, column: 9, type: '' }
	{ line: 19, column: 10, type: 'enter' }
	{ line: 19, column: 17, type: '' }
	{ line: 14, column: 9, type: 'enter' }
	{ line: 14, column: 16, type: '' }
	{ line: 19, column: 21, type: 'exit' }
	{ line: 20, column: 9, type: 'exit' }



How it Works
-------------------
Like Benbria CoffeeCoverage, it walks the AST node and inserts instrumented node before statement. To trace entering a function, I just simply add ide.trace code at the first line of every function body as post operation of Depth-first Search. As for exiting a function, it's a little complicate. At first I tried to insert instrumented code into Return node. Like that,

	return (__ = the content of return, ide.trace({..,'exit'}), __)
	
But I found some problems. Like Ruby, the last line of CoffeeScript function body is always return value. So I explicitly add Return tag around the last line. But in CoffeeScript, it allows the expression like 

	fun (x)-> return if x>3 then return 534 else 123

You may get some problems something like "cannot use a pure statement in an expression" if you use the above way. I don't know how to handle this situation, but if you look at the compiled javascript it works good. I think the process of transforming .coffee to .js may handle this return situation for each node type. So for simplicity at first I choose another way of emitting exiting function event. i.e, add instrumented node after function call. So this attempt looks like this

	(__ = fun1(param1,param2), ide.trace(..,'exit of fun1'),__)

But this approach doesn't take the exception into account. When a error occurs, it would wrap stacks until it finds the nearest catch block. So I use finally block to ensure ide.trace(..., 'exit') will called after the function end, like this

	var fun = function(..) {
		ide.trace(..,'enter')
		try {
			// function body..
		} finally {
			ide.trace(..,'exit')
		}
	}
	

Also, One thing I notcie is that the trace of execution line use Block AST. So you cannot get event in the place like predicate of 'If' or 'While' if it is just a Value node. So you want more detail debug, you can instrument node for each AST Node type. But then I found another simple way to tackle this.

For example,

	switch day
	  when "Mon" then 1
	  when "Sun" then 7
	  
Then the AST is

	Switch
    	Value "day"
    	Value ""Mon""
    	Block
      		Value "1"
        Value ""Sun""
        Block
      		Value "7"


So when the day equals "Sun", it will directly jump to "go home" line. It will not pause at the line which will compare to "Mon". Since "Mon" is not contained in the Block AST. But I found if you include bracket around "Mon" like `when ("Mon") then 1`. It makes the AST like this

	Switch
    	Value "day"
    	Value
      		Parens
        		Block
          			Value ""Mon""
    	Block
      		Value "1"
    	Value ""Sun""
    	Block
      		Value "7"

So it will make instrumented code before Value ""Mon"" since it is contained in the Block AST. So the overall solution is for each AST type you want to get detail debug but don't, you just put Parens-Block AST on the Value if not exist (for example, condition part of If, While, Switch). I do not implement this feature in this version.

