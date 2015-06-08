
# TSP - brute force


###
graph = {
  a: {
    b: 3
    c: 5
  }
  b: {
    a: 3
    c: 4
  }
  c: {
    a: 5
    b: 4
  }
}
###


graph = {
  a: {
    b: 5 
    c: 2
    d: 3
  }
  b: {
    a: 5
    c: 4
    d: 6
  }
  c: {
    a: 2
    b: 4
    d: 2
  }
  d: {
    a: 3
    b: 6
    c: 2
  }
}



# Borrowed from http://codereview.stackexchange.com/questions/59615/recursive-function-that-generates-the-permutations-of-a-string
# and converted to CoffeeScript
perms = (data) ->
  if not data instanceof Array
      throw new TypeError "input data must be an Array"

  data = data.slice() #copy Array
  permutations = []
  stack = []

  doPerm = ->
    if data.length == 0
      permutations.push(stack.slice())
    for i in [0...data.length]
      x = data.splice(i, 1)
      stack.push(x)
      doPerm()
      stack.pop()
      data.splice(i, 0, x)

  doPerm()
  return permutations


create_paths = (g, start_node) ->
  node_str = ""
  (node_str += k for own k of g when k != start_node)
  permutations = (start_node + r.join('') + start_node for r in perms(node_str.split('')))
  return permutations


calc_weights_for_paths = (g, paths) ->
  r = []
  for p in paths
    totlen = 0
    for i in [1...p.length]
      from = p[i-1]
      to   = p[i]
      totlen += g[from][to]
    r.push {len: totlen, path: p}

  return r


weighted_paths = calc_weights_for_paths(graph, create_paths(graph, 'a'))

sorted_paths = weighted_paths.sort (a, b) ->
  return a.len - b.len

console.log sorted_paths
