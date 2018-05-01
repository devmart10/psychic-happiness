package com.senproj.luna.map.blocks;

import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.math.Vector2;
import com.senproj.luna.collisions.Collidable;
import com.senproj.luna.collisions.CollisionBox;

public class SemisolidBlock extends OpaqueBlock implements Collidable {
    private CollisionBox collisionBox;

    public SemisolidBlock(float posX, float posY, BlockType type, TextureRegion tex) {
        super(posX, posY, type, tex);
        collisionBox = new CollisionBox(posX, posY, 1,1);
    }

    @Override
    public boolean isColliding(Collidable other) {
        return collisionBox.isColliding(other.getCollisionBox());
    }

    @Override
    public boolean wouldCollide(Collidable other, Vector2 vel) {
        return collisionBox.wouldCollide(other.getCollisionBox(), vel);
    }

    @Override
    public CollisionBox getCollisionBox() {
        return collisionBox;
    }
}
