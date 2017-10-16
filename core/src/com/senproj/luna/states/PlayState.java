package com.senproj.luna.states;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.senproj.luna.characters.Player;
import com.senproj.luna.helpers.Settings;
import com.senproj.luna.map.GameMap;

public class PlayState extends GameState {
    private Player player;
    private GameMap gamemap;

    public PlayState(GameStateManager gsm) {
        super(gsm);
        gamemap = new GameMap();
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
        gamemap.draw(batch);
        player.draw(batch);
        batch.end();
    }

    @Override
    public void handleInput() {
        if (Gdx.input.isKeyPressed(Input.Keys.ESCAPE)) {
            Gdx.app.exit();
        }
    }

    @Override
    public void dispose() {
        gamemap.dispose();
        player.dispose();
    }
}
