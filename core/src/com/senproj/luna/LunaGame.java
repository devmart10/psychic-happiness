package com.senproj.luna;

import com.badlogic.gdx.Application;
import com.badlogic.gdx.Game;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.utils.Logger;
import com.senproj.luna.states.GameStateManager;
import com.senproj.luna.states.MenuState;


public class LunaGame extends Game {
    private GameStateManager gsm;
    public static SpriteBatch batch;
    public static Logger logger;

    @Override
    public void create() {
        batch = new SpriteBatch();
        logger = new Logger("LunaGame");
        logger.setLevel(Logger.DEBUG);
        gsm = new GameStateManager();
	    gsm.pushState(new MenuState(gsm));
//        gsm.pushState(new PlayState(gsm));
        init();
    }

    private void init() {
        Gdx.app.setLogLevel(Application.LOG_DEBUG);
        Gdx.gl.glClearColor(0.2f, 0.2f, 0.2f, 1);
    }

    @Override
    /*
     * This method effectively functions as the game loop.
     * Because it is called every frame, we use this to
     * both render the screen and update the game.
     */
    public void render() {
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
        gsm.update(Gdx.graphics.getDeltaTime());
        gsm.render();
    }

    @Override
    public void dispose() {
        batch.dispose();
    }
}
