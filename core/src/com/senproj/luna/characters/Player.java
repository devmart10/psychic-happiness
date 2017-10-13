package com.senproj.luna.characters;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;
import com.senproj.luna.helpers.Settings;

public class Player {

    private float speed;
    private Vector2 pos, vel;
    private Texture tex;

    public Player() {
        tex = new Texture("game/sprites/player/temp_sprite_player_front.png");
        pos = new Vector2(Settings.SCREEN_WIDTH / 2.0f, Settings.SCREEN_HEIGHT / 2.0f);
        vel = new Vector2(0, 0);
        speed = 150;
    }

    public void update(float dt) {
        updateVelocity();
        pos.add(vel.scl(dt * speed));
    }

    public void draw(SpriteBatch batch) {
        batch.draw(tex, pos.x - tex.getWidth() / 2.0f, pos.y - tex.getHeight() / 2.0f);
    }

    public void dispose() {
        tex.dispose();
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
        if (Gdx.input.isKeyPressed(Input.Keys.A))
            vel.x = -1;
        else if (Gdx.input.isKeyPressed(Input.Keys.D))
            vel.x = 1;
        else
            vel.x = 0;
    }
}
