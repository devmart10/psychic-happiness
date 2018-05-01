package com.senproj.luna.states;

public abstract class GameState {
    protected GameStateManager gsm;

    protected GameState(GameStateManager gsm) {
        this.gsm = gsm;
    }

    public abstract void update(float dt);
    public abstract void render();
    public abstract void handleInput();
    public abstract void dispose();
}
