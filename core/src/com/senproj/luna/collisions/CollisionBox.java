package com.senproj.luna.collisions;

import com.badlogic.gdx.math.Vector2;

public class CollisionBox {
    private float posX, posY;
    private float width, height;

    public CollisionBox(float posX, float posY, float width, float height) {
        this.posX = posX;
        this.posY = posY;
        this.width = width;
        this.height = height;
    }

    public boolean isColliding(CollisionBox other) {
        return posX < other.posX + other.width &&
                posX + width > other.posX &&
                posY < other.posY + other.height &&
                posY + height > other.posY;
    }

    public boolean wouldCollide(CollisionBox other, Vector2 vel) {
        float tempOtherX = other.posX + vel.x, tempOtherY = other.posY + vel.y;
        return posX < tempOtherX + other.width &&
                posX + width > tempOtherX &&
                posY < tempOtherY + other.height &&
                posY + height > tempOtherY;
    }

    public float getPosX() {
        return posX;
    }

    public float getPosY() {
        return posY;
    }

    public float getWidth() {
        return width;
    }

    public float getHeight() {
        return height;
    }

    public void setPosition(Vector2 pos) {
        posX = pos.x;
        posY = pos.y;
    }
}
