import random
import godot
import godotapi/[animated_sprite, rigid_body_2d, sprite_frames, visibility_notifier_2d]

gdobj Mob of RigidBody2D:
  var animatedSprite: AnimatedSprite
  var visibilityNotifier2D: VisibilityNotifier2D

  method ready*() =
    self.animatedSprite = self.getNode("AnimatedSprite").as(AnimatedSprite)
    self.visibilityNotifier2D = self.getNode("VisibilityNotifier2D").as(VisibilityNotifier2D)
    self.animatedSprite.playing = true
    var mob_types = self.animatedSprite.frames().getAnimationNames()
    self.animatedSprite.animation = mob_types[rand(mob_types.len-1)]

    discard self.visibilityNotifier2D.connect("screen_exited", self, "on_visibility_notifier_screen_exited")

  proc onVisibilityNotifierScreenExited*() {.gdExport.} =
    self.queueFree()
