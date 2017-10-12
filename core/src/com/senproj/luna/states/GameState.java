package com.senproj.luna.states;

import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;

public abstract class GameState {
    protected OrthographicCamera camera;
    protected GameStateManager gsm;

    protected GameState(GameStateManager gsm) {
        this.gsm = gsm;
        camera = new OrthographicCamera();
    }

    public abstract void update(float dt);
    public abstract void render(SpriteBatch batch);
    public abstract void handleInput();
    public abstract void dispose();
}
