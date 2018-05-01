package com.senproj.luna.sprites;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.graphics.g2d.Animation;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.math.Vector2;
import com.senproj.luna.animations.AnimationFactory;
import com.senproj.luna.animations.AnimationState;
import com.senproj.luna.collisions.Collidable;
import com.senproj.luna.collisions.CollisionBox;
import com.senproj.luna.map.GameMap;
import com.senproj.luna.map.blocks.Block;
import com.senproj.luna.render.RenderManager;
import com.senproj.luna.render.Renderable;

import java.util.HashMap;
import java.util.Map;

public class Player implements Collidable, Renderable {

    // Number of tiles player takes up
    private static final int PLAYER_WIDTH = 4, PLAYER_HEIGHT = 4;
    private static final float SPEED = 15, JUMP_STRENGTH = 5, GRAVITY = -10;
    private Map<AnimationState, Animation<TextureRegion>> animations;
    private AnimationState currentState;
    private float animationTime;
    private Vector2 pos, vel, acc;
    private boolean isGrounded = false;

    private CollisionBox collisionBox;

    private GameMap gameMap;

    public Player(GameMap gameMap) {
        /* TODO: Fill this in with actual values gained from a getPlayerPosition method in World
         based on either the world spawn location (for new games) or the last known player loc (for saved games)*/
        pos = new Vector2(20, 4);
        vel = new Vector2(0, 0);
        acc = new Vector2(0, GRAVITY);
        collisionBox = new CollisionBox(pos.x, pos.y, PLAYER_WIDTH, PLAYER_HEIGHT);

        this.gameMap = gameMap;

        loadAnimations();
    }

    public void update(float dt) {
        updateVelocity(dt);

        pos.add(new Vector2(vel).scl(dt));
        collisionBox.setPosition(pos);
        animationTime += dt;
    }

    @Override
    public boolean isColliding(Collidable other) {
        return collisionBox.isColliding(other.getCollisionBox());
    }

    @Override
    public boolean wouldCollide(Collidable other, Vector2 otherVel) {
        return collisionBox.wouldCollide(other.getCollisionBox(), otherVel);
    }

    private boolean canJump() {
        if (!isGrounded) {
            return false;
        }

        Vector2 potentialVel = new Vector2(vel).add(new Vector2(acc).add(0, JUMP_STRENGTH));
        Block[][] world = gameMap.getWorld();
        int worldPosX = (int)pos.x, toCheckY = ((int)pos.y) + PLAYER_HEIGHT;
        for (int i = worldPosX; i > 0 && i < world.length && i < worldPosX + PLAYER_WIDTH; i++) {
            if (world[i][toCheckY] instanceof Collidable) {
                CollisionBox otherBox = ((Collidable)world[i][toCheckY]).getCollisionBox();
                if (otherBox.wouldCollide(collisionBox, potentialVel)) {
                    return false;
                }
            }
        }

        return true;
    }

    /**
     * Preemptive collision check to see if the player can move sideways
     * @param dir -1 for left, 1 for right
     * @return true if can move sideways, false otherwise
     */
    private boolean canMoveSideways(int dir, float dt) {
        Vector2 potentialVel = new Vector2(dir * dt, 0);
        Block[][] world = gameMap.getWorld();
        int worldPosY = (int)pos.y;
        int toCheckX = dir > 0 ? ((int)pos.x) + PLAYER_WIDTH + 1: (int)pos.x - 1;
        if (toCheckX >= world.length || toCheckX < 0) {
            return false;
        }
        for (int j = worldPosY; j < world[toCheckX].length && j < worldPosY + PLAYER_WIDTH; j++) {
            Block comp = world[toCheckX][j];
            if (comp instanceof Collidable) {
                if (((Collidable)comp).getCollisionBox().wouldCollide(collisionBox, potentialVel)) {
                    return false;
                }
            }
        }

        return true;
    }

    @Override
    public TextureRegion getTex() {
        return animations.get(currentState).getKeyFrame(animationTime, true);
    }

    @Override
    public float getPosX() {
        return pos.x;
    }

    @Override
    public float getPosY() {
        return pos.y;
    }

    @Override
    public CollisionBox getCollisionBox() {
        return collisionBox;
    }

    @Override
    public void render() {
        RenderManager.queueRenderable(this);
        RenderManager.queueDrawBox(collisionBox);
    }

    public void dispose() {

    }

    private void updateVelocity(float dt) {
        if (Gdx.input.isKeyPressed(Input.Keys.W) && canJump()) {
            isGrounded = false;
            vel.add(0, JUMP_STRENGTH);
        } else if (Gdx.input.isKeyPressed(Input.Keys.S)) { // TODO: Crouch?

        }

        if (Gdx.input.isKeyPressed(Input.Keys.A) && canMoveSideways(-1, dt)) {
            vel.x = -1 * SPEED;
        } else if (Gdx.input.isKeyPressed(Input.Keys.D) && canMoveSideways(1, dt)) {
            vel.x = 1 * SPEED;
        } else {
            vel.x = 0;
        }

        if (!checkIsGrounded(dt)) {
            vel.add(new Vector2(acc).scl(dt));
            vel.y = Math.max(vel.y, -3);
        } else {
            vel.y = 0;
            pos.y = ((int)pos.y) + 1.0001f;
            isGrounded = true;
        }

        if (Math.abs(vel.x) <= 0.0001) {
            currentState = AnimationState.IDLE;
        }
        else if (vel.x < -0.0001) {
            currentState = AnimationState.WALK_LEFT;
        }
        else if (vel.x > 0.0001) {
            currentState = AnimationState.WALK_RIGHT;
        }
    }

    private boolean checkIsGrounded(float dt) {
        Block[][] world = gameMap.getWorld();
        int worldCoordX = (int)pos.x, worldCoordY = (int)pos.y;
        for (int i = worldCoordX; i < worldCoordX + PLAYER_WIDTH + 1; i++) {
            for (int j = worldCoordY; j > 0 && j >= worldCoordY - 1; j--) {
                if (world[i][j] instanceof Collidable) {
                    if (((Collidable) world[i][j]).getCollisionBox().isColliding(collisionBox)) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    private void loadAnimations() {
        animationTime = 0;
        animations = new HashMap<>();
        currentState = AnimationState.IDLE;

        boolean debug = false;
        if (debug) {
            animations.put(AnimationState.IDLE, AnimationFactory.createAnimation("game/sprites/player/ss_luna_idle_DEBUG.png",
                    2, 2, 0, 1, 1, 0, 0.5f));
            animations.put(AnimationState.WALK_RIGHT, AnimationFactory.createAnimation("game/sprites/player/ss_luna_walking_DEBUG.png",
                    2, 2, 0, 1, 2, 0, 0.3f));
            animations.put(AnimationState.WALK_LEFT, AnimationFactory.createAnimation("game/sprites/player/ss_luna_walking_DEBUG.png",
                    2, 2, 0, 1, 2, 1, 0.3f));
        } else {
            animations.put(AnimationState.IDLE, AnimationFactory.createAnimation("game/sprites/player/ss_luna_idle.png",
                    2, 2, 0, 1, 1, 0, 0.5f));
            animations.put(AnimationState.WALK_RIGHT, AnimationFactory.createAnimation("game/sprites/player/ss_luna_walking.png",
                    2, 2, 0, 1, 2, 0, 0.3f));
            animations.put(AnimationState.WALK_LEFT, AnimationFactory.createAnimation("game/sprites/player/ss_luna_walking.png",
                    2, 2, 0, 1, 2, 1, 0.3f));
        }
    }
}
