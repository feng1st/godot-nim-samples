import random, math
import godot
import godotapi/[audio_stream_player, node, packed_scene, path_follow_2d,
    position_2d, rigid_body_2d, scene_tree, timer]
import hud, mob, player

gdobj Main of Node:
  var mobScene* {.gdExport.}: PackedScene
  var score: int
  var hud: HUD
  var player: Player
  var startPosition: Position2D
  var mobSpawnLocation: PathFollow2D
  var mobTimer: Timer
  var scoreTimer: Timer
  var startTimer: Timer
  var music: AudioStreamPlayer
  var deathSound: AudioStreamPlayer

  method ready*() =
    self.hud = self.getNode("HUD").as(HUD)
    self.player = self.getNode("Player").as(Player)
    self.startPosition = self.getNode("StartPosition").as(Position2D)
    self.mobSpawnLocation = self.getNode("MobPath/MobSpawnLocation").as(PathFollow2D)
    self.mobTimer = self.getNode("MobTimer").as(Timer)
    self.scoreTimer = self.getNode("ScoreTimer").as(Timer)
    self.startTimer = self.getNode("StartTimer").as(Timer)
    self.music = self.getNode("Music").as(AudioStreamPlayer)
    self.deathSound = self.getNode("DeathSound").as(AudioStreamPlayer)

    randomize()

    discard self.player.connect("hit", self, "game_over")
    discard self.mobTimer.connect("timeout", self, "on_mob_timer_timeout")
    discard self.scoreTimer.connect("timeout", self, "on_score_timer_timeout")
    discard self.startTimer.connect("timeout", self, "on_start_timer_timeout")
    discard self.hud.connect("start_game", self, "new_game")

  proc gameOver*() {.gdExport.} =
    self.scoreTimer.stop()
    self.mobTimer.stop()
    self.hud.showGameOver()
    self.music.stop()
    self.deathSound.play()

  proc newGame*() {.gdExport.} =
    discard self.getTree().callGroup("mobs", "queue_free")
    self.score = 0
    self.player.start(self.startPosition.position)
    self.startTimer.start()
    self.hud.updateScore(self.score)
    self.hud.showGetReady()
    self.music.play()

  proc onMobTimerTimeout*() {.gdExport.} =
    # Choose a random location on Path2D.
    self.mobSpawnLocation.offset = rand(high(int)).float

    # Create a Mob instance and add it to the scene.
    var mob = self.mobScene.instance().as(RigidBody2D)
    self.addChild(mob)

    # Set the mob's direction perpendicular to the path direction.
    var direction = self.mobSpawnLocation.rotation + PI / 2

    # Set the mob's position to a random location.
    mob.position = self.mobSpawnLocation.position

    # Add some randomness to the direction.
    direction += rand(-PI/4..PI/4)
    mob.rotation = direction

    # Choose the velocity for the mob.
    var velocity = vec2(rand(150.0..250.0), 0.0)
    mob.linearVelocity = velocity.rotated(direction)

  proc onScoreTimerTimeout*() {.gdExport.} =
    self.score += 1
    self.hud.updateScore(self.score)

  proc onStartTimerTimeout*() {.gdExport.} =
    self.mobTimer.start()
    self.scoreTimer.start()
