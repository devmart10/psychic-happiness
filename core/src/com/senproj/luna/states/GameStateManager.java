package com.senproj.luna.states;

import com.badlogic.gdx.graphics.g2d.SpriteBatch;

import java.util.Stack;

public class GameStateManager {

    private Stack<GameState> states;

    public GameStateManager() {
        states = new Stack<>();
    }

    public void pushState(GameState state) {
        states.push(state);
    }

    public void popState() {
        states.pop();
    }

    public void setState(GameState state) {
        states.pop();
        states.push(state);
    }

    public void update(float dt) {
        states.peek().update(dt);
    }

    public void render(SpriteBatch batch) {
        states.peek().render(batch);
    }
}
