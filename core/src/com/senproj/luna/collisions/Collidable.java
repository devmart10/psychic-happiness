package com.senproj.luna.collisions;

import com.badlogic.gdx.math.Vector2;

public interface Collidable {

    boolean isColliding(Collidable other);
    boolean wouldCollide(Collidable other, Vector2 vel);

    CollisionBox getCollisionBox();
}
