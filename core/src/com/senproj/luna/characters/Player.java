package com.senproj.luna.characters;

import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;
import com.senproj.luna.helpers.Settings;

public class Player {

    private Vector2 pos;
    private Texture tex;

    public Player() {
        tex = new Texture("game/sprites/player/temp_sprite_player_front.png");
        pos = new Vector2(Settings.SCREEN_WIDTH / 2.0f - tex.getWidth() / 2.0f, Settings.SCREEN_HEIGHT / 2.0f - tex.getHeight() / 2.0f);
    }

    public void draw(SpriteBatch batch) {
        batch.draw(tex, pos.x, pos.y);
    }

    public void dispose() {
        tex.dispose();
    }

    public Vector2 getPosition() {
        return pos;
    }
}
