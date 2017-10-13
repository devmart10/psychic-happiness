package com.senproj.luna.states;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;
import com.senproj.luna.characters.Player;
import com.senproj.luna.helpers.Settings;

public class PlayState extends GameState {
    private Player player;
    private Texture gamemap;

    public PlayState(GameStateManager gsm) {
        super(gsm);
        gamemap = new Texture("game/map/background/temp_ingamemap.png");
        player = new Player();
        camera.setToOrtho(false, Settings.SCREEN_WIDTH / 2.0f, Settings.SCREEN_HEIGHT / 2.0f);
    }

    @Override
    public void update(float dt) {
        player.update(dt);
        camera.position.set(player.getPosition(), camera.position.z);
        camera.update();
        handleInput();
    }

    @Override
    public void render(SpriteBatch batch) {
        batch.setProjectionMatrix(camera.combined);
        batch.begin();
        batch.draw(gamemap, 0, 0, Settings.SCREEN_WIDTH, Settings.SCREEN_HEIGHT);
        player.draw(batch);
        batch.end();
    }

    @Override
    public void handleInput() {

    }

    @Override
    public void dispose() {
        gamemap.dispose();
        player.dispose();
    }
}
