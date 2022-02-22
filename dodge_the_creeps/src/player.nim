import godot
import godotapi/[animated_sprite, area_2d, collision_shape_2d, input]

gdobj Player of Area2D:
  var speed* {.gdExport.} = 400
  var animatedSprite: AnimatedSprite
  var collisionShape2D: CollisionShape2D
  var screenSize: Vector2

  method init*() =
    self.addUserSignal("hit")

  method ready*() =
    self.animatedSprite = self.getNode("AnimatedSprite").as(AnimatedSprite)
    self.collisionShape2D = self.getNode("CollisionShape2D").as(CollisionShape2D)
    self.screenSize = self.getViewPortRect().size
    self.hide()
    discard self.connect("body_entered", self, "on_player_body_entered")

  method process*(delta: float64) =
    var velocity = vec2()
    if isActionPressed("move_right"):
      velocity.x += 1
    if isActionPressed("move_left"):
      velocity.x -= 1
    if isActionPressed("move_down"):
      velocity.y += 1
    if isActionPressed("move_up"):
      velocity.y -= 1

    if velocity.length() > 0:
      velocity = velocity.normalized() * self.speed
      self.animatedSprite.play()
    else:
      self.animatedSprite.stop()

    var position = self.position
    position += velocity * delta
    position.x = clamp(position.x, 0.0, self.screenSize.x)
    position.y = clamp(position.y, 0.0, self.screenSize.y)
    self.position = position

    if velocity.x != 0:
      self.animatedSprite.animation = "right"
      self.animatedSprite.flipV = false
      self.animatedSprite.flipH = velocity.x < 0
    elif velocity.y != 0:
      self.animatedSprite.animation = "up"
      self.animatedSprite.flipV = velocity.y > 0

  proc start*(pos: Vector2) =
    self.position = pos
    self.show()
    self.collisionShape2D.disabled = false

  proc onPlayerBodyEntered*(body: Node2D) {.gdExport.} =
    self.hide() # Player disappears after being hit.
    self.emitSignal("hit")
    # Must be deferred as we can't change physics properties on a physics callback.
    self.collisionShape2D.setDeferred("disabled", newVariant(true))
