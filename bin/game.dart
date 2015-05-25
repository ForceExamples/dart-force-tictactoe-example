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
    String key = "$uid";
    
    games[key] = new Game();
    
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
    print(vme.json);
    int x = vme.json['x'];
    int y = vme.json['y'];
    
    Game game = games["$uid"];
    game.play(vme.profile['name'], x, y);
    
    sender.sendToProfile('name', opponent, 'move', { 'gameId' : uid, 'x' : x, 'y' : y });
    
  }
  
}

class Game {
  List<List> playlist=[ ['-','-','-'], ['-','-','-'], ['-','-','-'] ]; 
  
  String turn;
  
  bool play(String user, int x, int y) {
    if (user==turn) playlist[x][y] = user;
    return false;
  }
}