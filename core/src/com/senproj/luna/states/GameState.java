package com.senproj.luna.states;

import com.badlogic.gdx.graphics.OrthographicCamera;

public abstract class GameState {
    protected OrthographicCamera camera;
    protected GameStateManager gsm;

    protected GameState(GameStateManager gsm) {
        this.gsm = gsm;
        camera = new OrthographicCamera();
    }

    public abstract void update(float dt);
    public abstract void render();
    public abstract void handleInput();
    public abstract void dispose();
}
