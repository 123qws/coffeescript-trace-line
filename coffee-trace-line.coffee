fileName = process.argv[2]
fs = require 'fs'
coffee = require 'coffee-script'
content = fs.readFileSync fileName, 'utf8'
tokens = coffee.tokens content
ast = coffee.nodes(tokens)
nodeType = (node) -> return node?.constructor?.name or null

#debug = console.log
debug = ->

fixLocationData = (instrumentedLine, line) ->
  doIt = (node) ->
    node.locationData =
      first_line: line - 1 # -1 because `line` is 1-based
      first_column: 0
      last_line: line - 1
      last_column: 0
    doIt instrumentedLine
    instrumentedLine.eachChild doIt

instrumentTree = (node, parent=null, depth=0) =>
  if (nodeType(node) != "Block")
    # pre operation
        
    # run for every child
    # node.eachChild (child)=>instrumentTree child, node, depth+1
    if nodeType(node) is "Array"
      for i in [0...node.length]
          node[i] = instrumentTree node[i], node, depth+1
    else if node.children?
      for attr in node.children
        if node[attr]?
          node[attr] = instrumentTree node[attr], node, depth+1
    
    # post operation
    if nodeType(node) is "If" and node.isChain
      node.isChain = false
    if nodeType(node) is "Code" # add the instrumented line in the first line function body to indicate enter
      line = node.locationData.first_line + 1
      column = node.locationData.first_column
      instrumentedLine = coffee.nodes("ide.trace({line:#{line},column:#{column},type:'enter'})")
      fixLocationData instrumentedLine, line
      node.body.expressions.splice(0, 0, instrumentedLine)
    if nodeType(node) is "Call" # add the instrumented line after every function call to indicate exit
      line = node.locationData.first_line + 1
      column = node.locationData.first_column
      block = coffee.nodes("")
      fixLocationData block, line
      assign = coffee.nodes("__=__").expressions[0]
      fixLocationData assign, line
      assign.value = node
      block.push(assign)
      instrumentedLine = coffee.nodes("ide.trace({line:#{line},column:#{column},type:'exit'})")
      fixLocationData instrumentedLine, line
      block.push(instrumentedLine)
      variable = coffee.nodes("__").expressions[0]
      fixLocationData variable, line
      block.push(variable)
      value = coffee.nodes("(1)").expressions[0]
      value.base.body = block
      node = value
      
  else
    children = node.expressions
    childIndex = 0
    while childIndex < children.length
      expr = children[childIndex]
      line = expr.locationData.first_line + 1
      column = expr.locationData.first_column
      instrumentedLine = coffee.nodes("ide.trace({line:#{line},column:#{column},type:''})")
      fixLocationData instrumentedLine, line
      children.splice childIndex, 0, instrumentedLine
      children[childIndex+1] = instrumentTree expr, node, depth+1
      childIndex += 2

  return node

ast = instrumentTree ast
# console.log ast.toString()
js = ast.compile {}
console.log js
