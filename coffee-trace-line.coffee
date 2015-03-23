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
    node.eachChild (child)=>instrumentTree child, node, depth+1
    
    # post operation
    if nodeType(node) is "If" and node.isChain
      node.isChain = false
    if nodeType(node) is "Code"
      line = node.locationData.first_line + 1
      column = node.locationData.first_column
      # add the instrumented line in the finally block to indicate enter
      tryNode = coffee.nodes("try {} finally {}").expressions[0]
      fixLocationData tryNode, line
      instrumentedLine = coffee.nodes("ide.trace({line:#{line},column:#{column},type:'exit'})")
      fixLocationData instrumentedLine, line      
      tryNode.ensure = instrumentedLine
      tryNode.attempt = node.body
      blockNode = coffee.nodes("")
      fixLocationData blockNode, line
      blockNode.push(tryNode)
      # add the instrumented line in the first line function body to indicate enter
      instrumentedLine = coffee.nodes("ide.trace({line:#{line},column:#{column},type:'enter'})")
      fixLocationData instrumentedLine, line
      blockNode.expressions.splice(0, 0, instrumentedLine)
      node.body = blockNode
      
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
      instrumentTree expr, node, depth+1
      childIndex += 2

instrumentTree ast

# console.log ast.toString()
js = ast.compile {}
console.log js
