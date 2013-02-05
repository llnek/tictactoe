
  <header>
  <span id="scoreX" class="score">000</span>
    <span id="title">Tic Tac Toe</span>
  <span id="scoreO" class="score">000</span>
  </header>

  <section id="tictactoe">
    <section id="layers">
      <canvas id="bg" width="500" height="420"></canvas>
      <canvas id="ui" width="500" height="420"></canvas>
      <canvas id="game" width="500" height="420"></canvas>
    </section>
    <form id="menu" class="form-horizontal">
      <span>Level: </span>
      <select id="level">
        <option value="1">Casual</option>
        <option value="2">Normal</option>
        <option value="3">Hardcore</option>
      </select>
      <a href="#" class="btn btn-info" id="play"><i class="icon-play icon-white"></i> Play</a>
      <a href="#" class="btn btn-info" id="stop"><i class="icon-stop icon-white"></i> Stop</a>
    </form>
  </section>


