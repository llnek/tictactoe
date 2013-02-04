`
require([
  "use!jquery",
  "use!underscore",
  "use!backbone",
],
function($,_,Backbone,undefined) {
"use strict";
function _isx(obj) { return typeof obj !== 'undefined' && obj !== null; }
var C_BG=0,
C_UI=1,
C_GAME=2,
C_CELL_WIDTH=60,
C_GRIDCLR='#fff',
O_CLR= '#8ADE35',
X_CLR= '#F59631';


`

class Circle #{
  constructor: (@x,@y,@radius) ->
  draw: (ctx,styleObj)->
    ctx.beginPath()
    ctx.strokeStyle=styleObj.stroke.style
    ctx.lineWidth=styleObj.line.width
    ctx.arc(@x, @y, @radius, 0, 2 * Math.PI, true)
    ctx.stroke()
#}

class Line #{
  constructor: (@x1,@y1,@x2,@y2) ->
  draw: (ctx,styleObj)->
    ctx.beginPath()
    ctx.moveTo(@x1,@y1)
    ctx.lineTo(@x2,@y2)
    ctx.strokeStyle = styleObj.stroke.style
    ctx.lineWidth=styleObj.line.width
    if styleObj.line.cap? then ctx.lineCap= styleObj.line.cap
    ctx.stroke()
#}

class TextStyle #{
  constructor:()->
    @font = "14px 'Architects Daughter'"
    @fill= "#dddddd"
    @align = "left"
    @base= "top"

#}

class TicTacToe #{
  constructor:(@size=3,@players=1)->
    @cells= @size * @size
    @X= @size * -1
    @O= @size
    @layers= _.map(['bg','ui','game'], (v) ->
      $('#tictactoe #'+v)[0].getContext('2d')
    )
    @mapGoalSpace()

  cls: (ctx) -> ctx.clearRect(0,0, ctx.canvas.width, ctx.canvas.height)

  loadAssets:()->
    dfd=$.Deferred()
    me=this
    nok=(msg)-> alert('dude, no good\n'+msg)
    ok=() -> me.build()
    @scoreX=0
    @scoreO=0
    @bgImg=new Image()
    @bgImg.onerror=() -> dfd.reject('Error while loading background image')
    @bgImg.onload=() -> dfd.resolve()
    @bgImg.src='/public/images/bg.png'
    $.when( dfd.promise()).then( ok, nok)

  inizEvents:()->
    em=$('#tictactoe #layers')
    me=this
    em.mousedown((ev)-> me.onLeftMouseDown(ev))
    $('#tictactoe #play').on('click', ()-> me.onPlay())
    $('#tictactoe #stop').on('click', ()-> me.onStop())

  build:()->
    @showBackdrop()
    @inizEvents()
    @readyForGame()

  readyForGame:()->
    @gameInProgress=false
    @maybeEnableInputs()
    @clsArena()
    @showMsg('Ready for a quick game with our Cyborg? ')

  onLeftMouseDown:(ev)->
    if @gameInProgress and @curActor is @X
      [mX,mY]=@offset(ev)
      res=@checkOffset(mX,mY)
      if _isx(res) then @checkInput(res)

  onPlay:()->
    if @gameInProgress isnt true
      me=this
      @gameInProgress=true
      @level= parseInt( $('#tictactoe #level').val(), 10)
      @inizGameData()
      @clsArena()
      @maybeDisableInputs()
      a = if @curActor is @X then 'You move' else 'Cyborg moves'
      @showMsg("Game Started! " + a + " first ...")
      cb=()->
        if me.curActor is me.O then me.cyborgMove()
      @syncPlayerState(cb)

  onStop:()->
    if @gameInProgress is true
      @gameInProgress=false
      # if cyborg is thinking, stop after his move
      if @curActor is @X then @onStopReset()

  onStopReset: () ->
    @nukeGame()
    @showMsg('Game stopped.  Play a New Game ? ')

  nukeGame:()->
    @gameInProgress=false
    @maybeEnableInputs()
    @clsStates()

  checkWin: () ->
    winner= @findWinner()
    if winner is @X or winner is @O or winner is 911 then @endGame(winner) else @toggleActor()

  findWinner: () ->
    sum=0
    for i in [0...@cells]
      sum += @grid[i]
      if ((i+1) % @size) is 0
        winner= @matchXO(sum)
        if _isx(winner) then return winner else sum=0

    for i in [0...@size]
      sum=0
      p=i
      while p < @cells
        sum += @grid[p]
        p += @size
      winner= @matchXO(sum)
      if _isx(winner) then return winner

    sum=0
    for i in [0...@dx.length]
      sum += @grid[ @dx[i]]
    winner= @matchXO(sum)
    if _isx(winner) then return winner
    sum=0
    for i in [0...@dy.length]
      sum += @grid[ @dy[i]]
    winner= @matchXO(sum)
    if _isx(winner) then return winner

    if _.include(@grid, 0) then null else 911

  matchXO:(sum) ->
    switch sum
      when @X then @X
      when @O then @O
      else null

  syncPlayerState: (cb) ->
    [ ctx, y, xh, xc ]= @clsStates()
    @styleText( ctx, new TextStyle() )
    if @curActor is @X
      msg='Your Turn...'
      x=xh
    else
      msg='Thinking...'
      x=xc
    setTimeout(()->
      ctx.fillText(msg, x, y)
      cb()
    , 500)

  clsStates: () ->
    ctx=  @layers[C_GAME]
    xc= @gX + @size*C_CELL_WIDTH + 25
    xh= @gX-120
    _y= @gY - 10
    ctx.clearRect(xc, _y, 120,64)
    ctx.clearRect(xh, _y, 120,64)
    [ ctx, @gY, xh, xc ]

  showBackdrop: () ->
    ctx=@layers[ C_BG ]
    @cls(ctx)
    ctx.drawImage(@bgImg, 0, 0)

  drawMisc: () ->
    ctx= @layers[C_UI]
    #ctx.font = "18px 'Happy Monkey'"
    #ctx.font = "18px 'Shadows Into Light Two'"
    #ctx.font = "14px 'Architects Daughter'"
    w=120 # rough width of text
    y=64
    @drawMiscEx(ctx, 'Human ', '#ddd', @gX-w, y, '"X"', X_CLR)
    @drawMiscEx(ctx, 'Cyborg ', '#ddd', @gX+@size*C_CELL_WIDTH+25, y, '"O"', O_CLR)

  drawMiscEx: (ctx, preText, c1, x, y, postText, c2) ->
    ctx.font = "14px 'Architects Daughter'"
    ctx.lineWidth = 2
    ctx.fillStyle = c1
    ctx.textAlign = "left"
    ctx.textBaseline = "bottom"
    w=ctx.measureText(preText).width
    ctx.fillText(preText, x,y)
    ctx.fillStyle = c2
    ctx.fillText(postText, x+w,y)

  drawGrid:()->
    ctx= @layers[C_UI]
    ctx.strokeStyle = C_GRIDCLR
    ctx.lineWidth = 1
    side= @size * C_CELL_WIDTH
    x= ( ctx.canvas.width - side ) /2
    #y= (ctx.canvas.height-side) /2
    y=100
    ctx.strokeRect( x,y, side,side)
    @gX=x
    @gY=y
    styleObj={ stroke: { style: C_GRIDCLR }, line: {width: 1} }
    for i in [1...@size]
      x1=x + i*C_CELL_WIDTH
      y1=y
      x2=x1
      y2=y1+side
      new Line(x1,y1,x2,y2).draw(ctx, styleObj)
      y1=y + i * C_CELL_WIDTH
      x1=x
      x2=x1 + side
      y2=y1
      new Line(x1,y1,x2,y2).draw(ctx, styleObj)

  endGame:(winner) ->
    switch winner
      when @X then msg='Human Wins!'
      when @O then msg='Cyborg Wins!'
      else msg= "It's a draw!"
    msg = msg + ' Play again?'
    @updateScoreBoard(winner)
    @nukeGame()
    @showMsg(msg)

  updateScoreBoard:(winner) ->
    switch winner
      when @X
        @scoreX += 1
        val=@scoreX
        em=$('#scoreX')
      when @O
        @scoreO += 1
        val=@scoreO
        em=$('#scoreO')
      else
        return
    s=if val < 10 then '00' else if val < 100 then '0' else ''
    s= s + val
    em.text(s)

  checkInput: (res) ->
    c= res[2]
    if @grid[c] isnt 0
      @showMsg('Invalid move, try again!')
    else
      @grid[c] = if @curActor is @X then -1 else 1
      @drawCell(res)
      @checkWin()

  showMsg: (msg) ->
    ctx=@layers[C_GAME]
    ctx.font = "14px 'Architects Daughter'"
    ctx.fillStyle = "#dddddd"
    ctx.textAlign = "left"
    ctx.textBaseline = "bottom"
    x= @gX-120
    y= @gY+@size*C_CELL_WIDTH+64
    ctx.clearRect(x,y-36, 400,36)
    ctx.fillText(msg, x,y)

  checkOffset:(x,y) ->
    col= -1
    row= -1
    p=@gX
    q=@gY
    ###
    console.log('gX='+p)
    console.log('gY='+q)
    console.log('x='+x)
    console.log('y='+y)
    ###
    for i in [0...@size]
      if x > p and x < (p + C_CELL_WIDTH) then col=i
      if y > q and y < (q + C_CELL_WIDTH) then row=i
      p += C_CELL_WIDTH
      q += C_CELL_WIDTH
    if col >= 0 and row >= 0 then [ row,col, row*@size+col ] else null

  offset: (ev) ->
    os=$('#tictactoe #layers').offset()
    mX=ev.pageX - os.left
    mY= ev.pageY - os.top
    #if is_alive(ev.originalEvent) and is_alive(ev.originalEvent.layerX)
    #mX = ev.originalEvent.layerX
    #mY = ev.originalEvent.layerY
    [mX,mY]

  drawCell: (res) ->
    ctx=@layers[C_GAME]
    row=res[0]
    col=res[1]
    x1=@gX+ col *C_CELL_WIDTH
    y1=@gY+ row *C_CELL_WIDTH
    x2=x1+C_CELL_WIDTH
    y2=y1+C_CELL_WIDTH
    x= (x2-x1)/2
    y= (y2-y1)/2
    r= C_CELL_WIDTH/2 - 8
    styleObj={ stroke: { style: C_GRIDCLR }, line: {width: 3} }
    if @grid[res[2]] is -1
      styleObj.stroke.style=X_CLR
      styleObj.line.cap='round'
      new Line(x1+x-r,y1+y-r,x1+x+r,y1+y+r,3).draw(ctx,styleObj)
      new Line(x1+x+r,y1+y-r,x1+x-r,y1+y+r,3).draw(ctx,styleObj)
    else
      styleObj.stroke.style=O_CLR
      new Circle(x1+x,y1+y,r,3).draw(ctx,styleObj)

  maybeEnableInputs:() ->
    $('#tictactoe #level').removeAttr('disabled')

  maybeDisableInputs:() ->
    $('#tictactoe #level').attr('disabled','disabled')

  clsArena: () ->
    @cls( @layers[C_GAME])
    @cls( @layers[C_UI])
    @drawGrid()
    @drawMisc()

  inizGameData: () ->
    @curActor=if Math.floor( Math.random() * 10) > 5 then @X else @O
    @grid=[]
    @dx=[]
    @dy=[]
    for i in [0... @cells]
      @grid[i]= 0
    for i in [0... @size]
      @dx[i]=0
      @dy[i]=0
    @dx[0]= @size-1
    @dy[0]=0
    for i in [1...@size]
      @dx[i] = @dx[i-1] + @size - 1
      @dy[i] = @dy[i-1] + @size + 1

  toggleActor:()->
    @curActor= if @curActor is @X then @O else @X
    me=this
    cb = () ->
      if me.curActor is me.O
        setTimeout(()->
          me.cyborgMove()
        ,2000)
    @syncPlayerState(cb)

  cyborgMove:()->
    switch @level
      when 1 then @cyborgCasual()
      when 2 then @cyborgNormal()
      when 3 then @cyborg()

  cyborgCasual:()->
    ###
    first check through and see if borg is poised to win by 1 move,
    if so, do it.  otherwise, just randomly make a move
    ###
    if not @scanForEasyWin() then @randomMove()

  cyborgNormal:()->
    ###
    a bit smarter than casual, knows how to block,defend!
    ###
    if not @scanForEasyWin()
      if not @defendNeeded() then @randomMove()

  cyborg:()->
    ###
    smarter than normal, knows how to attack
    ###
    if not @scanForEasyWin()
      if not @defendNeeded() then @calcBestMove()

  cyborgMakesMove:(cell)->
    if @gameInProgress is false
      @onStopReset()
    else
      @grid[cell]= 1
      @drawCell( @cellToRC(cell))
      @checkWin()

  defendNeeded:()->
    # if not hardcore, don't always block, act dumb sometimes...
    defend=if @level < 3 then  Math.floor(Math.random() * 10) > 5 else true
    if defend
      me=this
      cb= (pz) -> me.cyborgMakesMove(pz)
      for i in [0...@GOALSPACE.length]
        if @poisedToWin( @GOALSPACE[i], @X + 1, cb ) then return true
    return false

  calcBestMove:()->
    ###
    try corners, center
    ###
    c=[]
    for i in [0...@dx.length]
      if @grid[ @dx[i] ] is 0 then c.push( @dx[i] )
    for i in [0...@dy.length]
      if @grid[ @dy[i] ] is 0 then c.push( @dy[i] )
    len= c.length
    if len > 0
      pz= c[ Math.floor(Math.random() * len) ]
      @cyborgMakesMove(pz)
    else
      @randomMove()

  randomMove:()->
    p=@nextFreeCell()
    if p is -1 then @endGame(911) else @cyborgMakesMove(p)

  scanForEasyWin:() ->
    me=this
    cb= (pz) -> me.cyborgMakesMove(pz)
    for i in [0...@GOALSPACE.length]
      if @poisedToWin( @GOALSPACE[i], @O - 1, cb ) then return true
    return false

  poisedToWin:(goal, target, cb)->
    pz= -1
    sum=0
    me=this
    for i in [0...goal.length]
      v=@grid[ goal[i] ]
      sum += v
      if v is 0 then pz= goal[i]
    if sum is target
      setTimeout( ()->
        cb(pz)
      ,0)
      true
    else
      false

  cellToRC: (cell) ->
    [ Math.floor(cell / @size), cell % @size , cell ]

  nextFreeCell: ()->
    free=[]
    _.each(@grid, (v,i)->
      if v is 0 then free.push(i)
    )
    len=free.length
    pos= Math.floor( Math.random() * len)
    if len is 0 then -1 else free[pos]

  mapGoalSpace: () ->
    # rows
    @GOALSPACE=[]
    c=[]
    for i in [0...@cells]
      c.push(i)
      if ((i+1) % @size) is 0
        @GOALSPACE.push(c)
        c=[]

    # cols
    c=[]
    for i in [0...@size]
      p=i
      while p < @cells
        c.push(p)
        p += @size
      @GOALSPACE.push(c)
      c=[]

    # diags
    c=[]
    c[0]= @size-1
    for i in [1...@size]
      c[i] = c[i-1] + @size - 1
    @GOALSPACE.push(c)
    c=[]
    c[0]= 0
    for i in [1...@size]
      c[i] = c[i-1] + @size + 1
    @GOALSPACE.push(c)
    c=[]


  styleText: (ctx, styleObj) ->
    ctx.font = styleObj.font
    ctx.fillStyle = styleObj.fill
    ctx.textAlign = styleObj.align
    ctx.textBaseline = styleObj.base
    ctx

  run:()-> @loadAssets()
#}


`

$(function(){
  new TicTacToe(3,1).run();
});

});


`
