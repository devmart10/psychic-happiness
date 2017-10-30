package com.senproj.luna.characters;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.graphics.g2d.Animation;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.maps.objects.RectangleMapObject;
import com.badlogic.gdx.math.Intersector;
import com.badlogic.gdx.math.Rectangle;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.utils.Array;
import com.senproj.luna.animations.AnimationFactory;
import com.senproj.luna.animations.AnimationState;
import com.senproj.luna.helpers.Settings;
import com.senproj.luna.map.GameMap;

import java.util.HashMap;
import java.util.Map;

import static com.senproj.luna.LunaGame.batch;

public class Player {

    private static final float SPEED = 150;
    private GameMap gamemap;
    private float timer = 0f;
    private int time = 0;
    private Vector2 pos, vel;
    private Map<AnimationState, Animation<TextureRegion>> animations;
    private AnimationState currentState;
    private float animationTime;

    // temp
    private int oxygen;
    private int health;
    private int width, height;
    private Rectangle rectangle;

    public Player(GameMap gamemap) {
        this.gamemap = gamemap;
        animations = new HashMap<>();
        loadAnimations();
        pos = new Vector2(Settings.SCREEN_WIDTH / 2.0f, Settings.SCREEN_HEIGHT / 2.0f);
        vel = new Vector2(0, 0);
        animationTime = 0;

        // temp
        oxygen = 20;
        health = 50;
        width = 32;
        height = 32;
        rectangle = new Rectangle(pos.x, pos.y, width, height);
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
        vel.scl(dt * SPEED);
        pos.add(vel);
        rectangle.setPosition(pos);

        checkCollisions();
        animationTime += dt;
    }

    private void checkCollisions() {
        Array<RectangleMapObject> objects = gamemap.getMap().getLayers().get("BuildingCollisions").getObjects().getByType(RectangleMapObject.class);
        for (RectangleMapObject object : objects) {
            Rectangle other = object.getRectangle();
            if (Intersector.overlaps(rectangle, other)) {
                // TODO: this is super lame
                pos.sub(vel);
                rectangle.setPosition(pos);
            }
        }
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
//        batch.draw(tex, pos.x - tex.getRegionWidth() / 2.0f, pos.y - tex.getRegionHeight() / 2.0f);
        batch.draw(tex, rectangle.x, rectangle.y);
        batch.end();
    }

    public void dispose() {

    }

    public Vector2 getPosition() {
        return pos;
    }

    private void updateVelocity() {
        if (Gdx.input.isKeyPressed(Input.Keys.W)) {
            vel.y = 1;
        } else if (Gdx.input.isKeyPressed(Input.Keys.S)) {
            vel.y = -1;
        } else {
            vel.y = 0;
        }

        if (Gdx.input.isKeyPressed(Input.Keys.A)) {
            vel.x = -1;
            currentState = AnimationState.WALK_LEFT;
        } else if (Gdx.input.isKeyPressed(Input.Keys.D)) {
            vel.x = 1;
            currentState = AnimationState.WALK_RIGHT;
        } else {
            vel.x = 0;
        }

        if (vel.isZero()) {
            currentState = AnimationState.IDLE;
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
