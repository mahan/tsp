
#Branch and bound TSP solution
#Adapted from https://www.youtube.com/watch?v=vNqE_LDTsa0


#N.B: access to this array is [y][x] (but does not matter as it's symetrical in this case)


###
  TMatrix encapsulates a twodimensional array with row and column names 
###
class TMatrix

  constructor: (@x_size, @y_size, row_names_csv, col_names_csv) ->
    @row_names = row_names_csv.split(",")
    @col_names = col_names_csv.split(",")
    @storage = []



  cell_idx: (x, y) ->
    if x < 0 or x >= @x_size or y < 0 or y >= @y_size
      throw "Exception: x: #{x} y: #{y} not valid for x_size: #{@x_size} y_size: #{@y_size}"
    return x+(y*@x_size)

  get: (x, y) ->
    v = @storage[@cell_idx(x, y)]
    return if v? then v else NaN

  put: (x, y, value) ->
    @storage[@cell_idx(x, y)] = value

  put_row_csv: (y, row_values_csv) ->
    rv = row_values_csv.split(",")
    for x in [0...@x_size]
      @put(x, y, if rv[x] != "" then rv[x] else NaN)

  #get row as array
  get_row: (y) ->
    r = []
    for x in [0...@x_size]
      r.push @get(x, y)
    return r

  #put array to row
  put_row: (y, row) ->
    for v, x in row
      @put(x, y, v)

  #get column as array
  get_col: (x) ->
    c = []
    for y in [0...@y_size]
      c.push @get(x, y)
    return c

  #put array to column
  put_col: (x, col) ->
    for v, y in col
      @put(x, y, v)


  foreach_value: (v, fn) ->
    for x in [0...@x_size]
      for y in [0...@y_size]
        if (v == @get(x, y))
          fn(x, y, v)

  print: ->
    s8 = "        "
    p = console.log
    o = s8
    for x in [0...@x_size]
      o += (s8 + @col_names[x])[-8..]
    p o

    for y in [0...@y_size]
      o = (@row_names[y] + s8)[...8]
      for x in [0...@x_size]
        o += (s8 + @get(x, y))[-8..]
      p o


row_minimization = (m) ->
  for y in [0...m.y_size]
    row = m.get_row(y)
    row_min = Math.min.apply(null, (v for v in row when not isNaN(v)))
    #console.log row_min
    for v, x in row
      if v?
        row[x] = row[x] - row_min
    m.put_row(y, row)


col_minimization = (m) ->
  for x in [0...m.x_size]
    col = m.get_col(x)
    col_min = Math.min.apply(null, (v for v in col when not isNaN(v)))
    #console.log "row_min" + row_min
    for v, y in col
      if v?
        col[y] = col[y] - col_min
    m.put_col(x, col)

find_max_penalty = (m) ->
  #Create a penalty matrix
  #pm = new TMatrix(m.x_size, m.y_size, m.row_names.join(","), m.col_names.join(","))
  max_penalty = {penalty: -1, x: -1, y: -1}
  m.foreach_value 0, (x, y) ->
    row = m.get_row(y)
    col = m.get_col(x)
    col_min_exz = Math.min.apply(null, (v for v, iy in col when not isNaN(v) and y != iy))
    row_min_exz = Math.min.apply(null, (v for v, ix in row when not isNaN(v) and x != ix))
    penalty = ((if col_min_exz != Infinity then col_min_exz else 0) + (if row_min_exz != Infinity then row_min_exz else 0))
    console.log "x: #{x} y: #{y} row_min: #{row_min_exz} col_min: #{col_min_exz}"
    if penalty > max_penalty.penalty
      max_penalty = {penalty: penalty, x: x, y: y}

  return max_penalty


remove_max_penalty = (m, max_penalty) ->
  #find both occurences of the path by column/row names:
  name1 = m.row_names[max_penalty.y]
  name2 = m.col_names[max_penalty.x]

  #console.log "name1: #{name1} name2: #{name2}"

  #Now set both intersections in maxtrix to NaN for these names (this path is already claimed.)
  y1 = m.row_names.indexOf(name1)
  y2 = m.row_names.indexOf(name2)

  x1 = m.col_names.indexOf(name2)
  x2 = m.col_names.indexOf(name1)

  #console.log "x1: #{x1} x2: #{x2}, y1: #{y1}, y2: #{y2}"

  if x1 >= 0 and x1 >= 0
    m.put(x1, y1, NaN)
  if x2 >= 0 and y2 >= 0  
    m.put(x2, y2, NaN)


reduce_matrix = (m, max_penalty) ->

  #Create a reduced matrix
  row_names = (n for n, ix in m.row_names when ix isnt max_penalty.x).join(",")
  col_names = (n for n, iy in m.row_names when iy isnt max_penalty.y).join(",")
  rm = new TMatrix(m.x_size-1, m.y_size-1, row_names, col_names)

  ny = 0
  for iy in [0...m.y_size]
    if iy != max_penalty.x
      nr = (v for v, ix in m.get_row(iy) when ix isnt max_penalty.y)
      rm.put_row(ny++, nr)

  return rm


main = ->

  #init
  mtx = new TMatrix(5, 5, "a,b,c,d,e", "a,b,c,d,e")
  mtx.put_row_csv(0, ",7,6,8,4")
  mtx.put_row_csv(1, "7,,8,5,6")
  mtx.put_row_csv(2, "6,8,,9,7")
  mtx.put_row_csv(3, "8,5,9,,8")
  mtx.put_row_csv(4, "4,6,7,8,")
  console.log "Initial:"
  mtx.print()

  paths = []


  while mtx.x_size > 1

    row_minimization(mtx)
    console.log "After row_minimization:"
    mtx.print()

    col_minimization(mtx)
    console.log "After col_minimization:"
    mtx.print()

    max_penalty = find_max_penalty(mtx)
    console.log "max_penalty: " + JSON.stringify max_penalty

    paths.push({from: mtx.row_names[max_penalty.y], to: mtx.col_names[max_penalty.x]})
    console.log "paths:"
    console.log paths

    remove_max_penalty(mtx, max_penalty)
    console.log "After remove_max_penalty:"
    mtx.print()


    mtx = reduce_matrix(mtx, max_penalty)
    console.log "Reduced matrix:"
    mtx.print()


main()
