package com.senproj.luna.states;

import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.senproj.luna.Settings;

public class PlayState extends GameState {
    private Texture gamemap;

    public PlayState(GameStateManager gsm) {
        super(gsm);
        gamemap = new Texture("game/map/background/temp_ingamemap");
    }

    @Override
    public void update(float dt) {

    }

    @Override
    public void render(SpriteBatch batch) {
        batch.begin();
        batch.draw(gamemap, 0, 0, Settings.SCREEN_WIDTH, Settings.SCREEN_HEIGHT);
        batch.end();
    }

    @Override
    public void handleInput() {

    }

    @Override
    public void dispose() {
        gamemap.dispose();
    }
}
