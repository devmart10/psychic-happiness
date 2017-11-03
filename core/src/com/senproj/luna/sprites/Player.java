package com.senproj.luna.sprites;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.graphics.g2d.Animation;
import com.badlogic.gdx.graphics.g2d.Sprite;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.*;
import com.senproj.luna.animations.AnimationFactory;
import com.senproj.luna.animations.AnimationState;
import com.senproj.luna.helpers.Settings;
import com.senproj.luna.map.GameMap;

import java.util.HashMap;
import java.util.Map;

import static com.senproj.luna.LunaGame.batch;

public class Player extends Sprite {

    private static final float SPEED = 150;
    private GameMap gamemap;
    private float timer = 0f;
    private int time = 0;
    private Map<AnimationState, Animation<TextureRegion>> animations;
    private AnimationState currentState;
    private float animationTime;

    // temp
    private int oxygen;
    private int health;
    private int width, height;

    public World world;
    public Body body;

    // determines the feel of walking
    private static final float dampenStrength = 20f;
    private static final float impulseStrength = 30f;

    public Player(GameMap gamemap, World world) {
        this.gamemap = gamemap;
        this.world = world;


        animations = new HashMap<>();
        loadAnimations();
        animationTime = 0;

        // temp
        oxygen = 20;
        health = 50;

        width = 32;
        height = 32;
        defineBody();
    }

    private void defineBody() {
        BodyDef bodyDef = new BodyDef();
        bodyDef.type = BodyDef.BodyType.DynamicBody;
        bodyDef.position.set(new Vector2(Settings.SCREEN_WIDTH / 2f, Settings.SCREEN_HEIGHT / 2f));
        body = world.createBody(bodyDef);

        FixtureDef fixtureDef = new FixtureDef();
        PolygonShape shape = new PolygonShape();
        shape.setAsBox(18, 16);

        fixtureDef.shape = shape;
        body.createFixture(fixtureDef);
        body.setLinearDamping(dampenStrength);
    }

    public void update(float dt) {
        timer += dt;
        float intervalInSeconds = 1f;
        if (this.timer >= intervalInSeconds) {
            time++;
            this.timer = 0;

            changeValues();
        }
        updateVelocity();

        checkCollisions();
        animationTime += dt;
    }

    private void checkCollisions() {

    }

    private void changeValues() {
        if (oxygen > 0) {
            oxygen -= 1;
        }

        if (oxygen == 0 && health > 0) {
            health -= 5;
        }
    }

    public int getOxygen() {
        return oxygen;
    }

    public void draw() {
        batch.begin();
        TextureRegion tex = animations.get(currentState).getKeyFrame(animationTime, true);
        batch.draw(tex, body.getPosition().x - width, body.getPosition().y - height / 2);
        batch.end();
    }

    public void dispose() {

    }

    public Vector2 getPosition() {
        return body.getPosition();
    }

    private void updateVelocity() {
        if (Gdx.input.isKeyPressed(Input.Keys.W)) {
            body.applyLinearImpulse(new Vector2(0, impulseStrength), body.getWorldCenter(), true);
        } else if (Gdx.input.isKeyPressed(Input.Keys.S)) {
            body.applyLinearImpulse(new Vector2(0, -impulseStrength), body.getWorldCenter(), true);
        }

        if (Gdx.input.isKeyPressed(Input.Keys.A)) {
            body.applyLinearImpulse(new Vector2(-impulseStrength, 0), body.getWorldCenter(), true);
        } else if (Gdx.input.isKeyPressed(Input.Keys.D)) {
            body.applyLinearImpulse(new Vector2(impulseStrength, 0), body.getWorldCenter(), true);
        }

        if (Math.abs(body.getLinearVelocity().x) < impulseStrength / 2) {
            currentState = AnimationState.IDLE;
        }
        else if (body.getLinearVelocity().x < 0) {
            currentState = AnimationState.WALK_LEFT;
        }
        else if (body.getLinearVelocity().x > 0) {
            currentState = AnimationState.WALK_RIGHT;
        }
    }

    private void loadAnimations() {
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

    public int getHealth() {
        return health;
    }
}
