package com.senproj.luna.states;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.senproj.luna.characters.Player;
import com.senproj.luna.helpers.Settings;
import com.senproj.luna.hud.Hud;
import com.senproj.luna.map.GameMap;

import static com.senproj.luna.LunaGame.batch;

public class PlayState extends GameState {
    private GameMap gamemap;
    private Player player;
    private Hud hud;

    public PlayState(GameStateManager gsm) {
        super(gsm);
        // might need later

        gamemap = new GameMap(camera);
        player = new Player(gamemap);
        hud = new Hud(player);
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
    public void render() {
        gamemap.render();

        batch.setProjectionMatrix(camera.combined);
        player.draw();
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
