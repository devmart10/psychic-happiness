package com.senproj.luna.states;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.senproj.luna.characters.Player;
import com.senproj.luna.helpers.Settings;
import com.senproj.luna.hud.Hud;
import com.senproj.luna.map.GameMap;

public class PlayState extends GameState {
    // may need reference later
    private SpriteBatch batch;

    private GameMap gamemap;
    private Player player;
    private Hud hud;

    public PlayState(GameStateManager gsm, SpriteBatch batch) {
        super(gsm);
        // might need later
        this.batch = batch;

        gamemap = new GameMap(camera);
        player = new Player();
        hud = new Hud(batch, player);
        camera.setToOrtho(false, Settings.SCREEN_WIDTH / 2.0f, Settings.SCREEN_HEIGHT / 2.0f);
    }

    @Override
    public void update(float dt) {
        player.update(dt);
        hud.update(dt);
        camera.position.set(player.getPosition(), camera.position.z);
        camera.update();
        handleInput();
    }

    @Override
    public void render(SpriteBatch batch) {
        gamemap.render();

        batch.setProjectionMatrix(camera.combined);
        batch.begin();
        player.draw(batch);
        batch.end();
        hud.stage.draw();
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
