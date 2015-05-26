part of multiplayer_example_force;

@Receivable
class GameReceiver {
  
  Map<String, Game> games;
  
  GameReceiver() {
      games = new Map<String, Game>();
  }
  
  @Receiver("start") 
  void onGameStart(MessagePackage vme, Sender sender) {
    String name = vme.json['opponent'];
    var uid = vme.json['gameId'];
    print("start game with $name");
    
    games["$uid"] = new Game(name, vme.profile['name']);
    
    sender.sendToProfile('name', name, 'start_game', { 'gameId' : uid, 'opponent' : vme.profile['name'] });
    
    List<String> opponents = new List<String>();
    opponents.add(name);
    opponents.add(vme.profile['name']);
    
    sender.send('leave', opponents);
  }
  
  @Receiver("play") 
  void onGamePlay(MessagePackage vme, Sender sender) {
    // String opponent = vme.json['opponent'];
    var uid = vme.json['gameId'];
    String opponent = vme.json['opponent'];
    int x = vme.json['x'];
    int y = vme.json['y'];
    
    Game game = games["$uid"];
    bool won = game.play(vme.profile['name'], x, y);
    
    sender.sendToProfile('name', opponent, 'move', { 'gameId' : uid, 'x' : x, 'y' : y });
    if (won) {
      sender.reply('won', { 'gameId' : uid });
      sender.sendToProfile('name', opponent, 'lost', { 'gameId' : uid });
    }
  }
  
}

class Game {
  List<List> board=[ ['-','-','-'], ['-','-','-'], ['-','-','-'] ]; 
  
  Map users = new Map();
  
  Game(playerA, playerB) {
    users[playerA] = "x";
    users[playerB] = "O";
  }
  
  String turn;
  
  bool play(String user, int x, int y) {
    if (user==turn) board[x][y] = users[user];
    return hasWon(users[user], x, y);
  }
  
  /** Return true if the player with "theSeed" has won after placing at
         (rowSelected, colSelected) */
  bool hasWon(theSeed, int rowSelected, int colSelected) {
        return (board[rowSelected][0] == theSeed  // 3-in-the-row
              && board[rowSelected][1] == theSeed
              && board[rowSelected][2] == theSeed
         || board[0][colSelected] == theSeed      // 3-in-the-column
              && board[1][colSelected] == theSeed
              && board[2][colSelected] == theSeed
         || rowSelected == colSelected            // 3-in-the-diagonal
              && board[0][0] == theSeed
              && board[1][1] == theSeed
              && board[2][2] == theSeed
         || rowSelected + colSelected == 2  // 3-in-the-opposite-diagonal
              && board[0][2] == theSeed
              && board[1][1] == theSeed
              && board[2][0] == theSeed);
  }
}