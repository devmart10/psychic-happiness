package com.senproj.luna.states;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.senproj.luna.Settings;

public class MenuState extends GameState {
    private Texture background;
    private Texture newGameButton;
    private Texture exitGameButton;

    public MenuState(GameStateManager gsm) {
        super(gsm);
        background = new Texture("menu/background/temp_mainmenu.png");
        newGameButton = new Texture("menu/button/new_game.png");
        exitGameButton = new Texture("menu/button/exit_game.png");
    }

    @Override
    public void update(float dt) {

    }

    @Override
    public void render(SpriteBatch batch) {
        batch.begin();
        batch.draw(background, 0, 0, Settings.SCREEN_WIDTH, Settings.SCREEN_HEIGHT);
        batch.draw(newGameButton,
                Settings.SCREEN_WIDTH / 2.0f - newGameButton.getWidth() / 2.0f,
                Settings.SCREEN_HEIGHT / 1.9f - newGameButton.getHeight() / 2.0f,
                newGameButton.getWidth(), newGameButton.getHeight());
        batch.draw(exitGameButton,
                Settings.SCREEN_WIDTH / 2.0f - exitGameButton.getWidth() / 2.0f,
                Settings.SCREEN_HEIGHT / 2.3f - exitGameButton.getHeight() / 2.0f,
                exitGameButton.getWidth(), exitGameButton.getHeight());
        batch.end();
    }

    @Override
    public void handleInput() {

    }

    @Override
    public void dispose() {
        background.dispose();
        newGameButton.dispose();
        exitGameButton.dispose();
    }
}
