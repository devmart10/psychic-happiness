package com.senproj.luna;

import com.badlogic.gdx.Application;
import com.badlogic.gdx.ApplicationAdapter;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.senproj.luna.states.GameStateManager;
import com.senproj.luna.states.MenuState;

public class LunaGame extends ApplicationAdapter {
    private GameStateManager gsm;
	private SpriteBatch batch;

	@Override
	public void create () {
		batch = new SpriteBatch();
		gsm = new GameStateManager();
	    gsm.pushState(new MenuState(gsm, batch));
//		gsm.pushState(new PlayState(gsm, batch));
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
	public void render () {
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		gsm.update(Gdx.graphics.getDeltaTime());
        gsm.render(batch);
	}
	
	@Override
	public void dispose () {
		batch.dispose();
	}
}
