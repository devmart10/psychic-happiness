package com.senproj.luna.states;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.senproj.luna.characters.Player;
import com.senproj.luna.helpers.Settings;

public class PlayState extends GameState {
    private Player player;
    private Texture gamemap;

    public PlayState(GameStateManager gsm) {
        super(gsm);
        gamemap = new Texture("game/map/background/temp_ingamemap.png");
        player = new Player();
        camera.setToOrtho(false);
    }

    @Override
    public void update(float dt) {
        camera.translate(player.getPosition());
        handleInput();
    }

    @Override
    public void render(SpriteBatch batch) {
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
