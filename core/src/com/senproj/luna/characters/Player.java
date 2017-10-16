package com.senproj.luna.characters;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.graphics.g2d.Animation;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.math.Vector2;
import com.senproj.luna.animations.AnimationFactory;
import com.senproj.luna.animations.AnimationState;
import com.senproj.luna.helpers.Settings;

import java.util.HashMap;
import java.util.Map;

public class Player {

    private static final float SPEED = 150;
    private Vector2 pos, vel;
    private Map<AnimationState, Animation<TextureRegion>> animations;
    private AnimationState currentState;
    private float animationTime;

    public Player() {
        animations = new HashMap<>();
        loadAnimations();
        pos = new Vector2(Settings.SCREEN_WIDTH / 2.0f, Settings.SCREEN_HEIGHT / 2.0f);
        vel = new Vector2(0, 0);
        animationTime = 0;
    }

    public void update(float dt) {
        updateVelocity();
        pos.add(vel.scl(dt * SPEED));
        animationTime += dt;
    }

    public void draw(SpriteBatch batch) {
        TextureRegion tex = animations.get(currentState).getKeyFrame(animationTime, true);
        batch.draw(tex, pos.x - tex.getRegionWidth() / 2.0f, pos.y - tex.getRegionHeight() / 2.0f);
    }

    public void dispose() {

    }

    public Vector2 getPosition() {
        return pos;
    }

    public void setVelocity(Vector2 velocity) {
        this.vel = velocity;
    }

    private void updateVelocity() {
        if (Gdx.input.isKeyPressed(Input.Keys.W))
            vel.y = 1;
        else if (Gdx.input.isKeyPressed(Input.Keys.S))
            vel.y = -1;
        else
            vel.y = 0;
        if (Gdx.input.isKeyPressed(Input.Keys.A)) {
            vel.x = -1;
            currentState = AnimationState.WALK_LEFT;
        }
        else if (Gdx.input.isKeyPressed(Input.Keys.D)) {
            vel.x = 1;
            currentState = AnimationState.WALK_RIGHT;
        }
        else
            vel.x = 0;
        if (vel.isZero()) {
            currentState = AnimationState.IDLE;
        }
    }

    private void loadAnimations() {
        currentState = AnimationState.IDLE;

        animations.put(AnimationState.IDLE, AnimationFactory.createAnimation("game/sprites/player/ss_luna_idle.png",
                2, 2, 0, 1, 1, 0, 0.5f));
        animations.put(AnimationState.WALK_RIGHT, AnimationFactory.createAnimation("game/sprites/player/ss_luna_walking.png",
                2, 2, 0, 1, 2, 0, 0.3f));
        animations.put(AnimationState.WALK_LEFT, AnimationFactory.createAnimation("game/sprites/player/ss_luna_walking.png",
                2, 2, 0, 1, 2, 1, 0.3f));
    }
}
