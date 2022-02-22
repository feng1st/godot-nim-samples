import godot
import godotapi/[button, canvas_layer, label, timer]

gdobj HUD of CanvasLayer:
  var scoreLabel: Label
  var messageLabel: Label
  var startMessageTimer: Timer
  var getReadyMessageTimer: Timer
  var startButton: Button
  var startButtonTimer: Timer

  method init*() =
    self.addUserSignal("start_game")

  method ready*() =
    self.scoreLabel = self.getNode("ScoreLabel").as(Label)
    self.messageLabel = self.getNode("MessageLabel").as(Label)
    self.startMessageTimer = self.getNode("StartMessageTimer").as(Timer)
    self.getReadyMessageTimer = self.getNode("GetReadyMessageTimer").as(Timer)
    self.startButton = self.getNode("StartButton").as(Button)
    self.startButtonTimer = self.getNode("StartButtonTimer").as(Timer)

    discard self.startButton.connect("pressed", self, "on_start_button_pressed")
    discard self.startButtonTimer.connect("timeout", self.startButton, "show")
    discard self.startMessageTimer.connect("timeout", self, "on_start_message_timer_timeout")
    discard self.getReadyMessageTimer.connect("timeout", self, "on_get_ready_message_timer_timeout")

  # There is no `yield` in GDNative, so we need to have every
  # step be its own method that is called on timer timeout.
  proc showGetReady*() =
    self.messageLabel.text = "Get Ready"
    self.messageLabel.show()
    self.getReadyMessageTimer.start()

  proc showGameOver*() =
    self.messageLabel.text = "Game Over"
    self.messageLabel.show()
    self.startMessageTimer.start()

  proc updateScore*(score: int) =
    self.scoreLabel.text = $score

  proc onStartButtonPressed*() {.gdExport.} =
    self.startButtonTimer.stop()
    self.startButton.hide()
    self.emitSignal("start_game")

  proc onStartMessageTimerTimeout*() {.gdExport.} =
    self.messageLabel.text = "Dodge the\nCreeps"
    self.messageLabel.show()
    self.startButtonTimer.start()

  proc onGetReadyMessageTimerTimeout*() {.gdExport.} =
    self.messageLabel.hide()
