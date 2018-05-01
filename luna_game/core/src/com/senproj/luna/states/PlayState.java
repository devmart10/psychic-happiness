package com.senproj.luna.states;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.math.Vector3;
import com.senproj.luna.helpers.CoordinateManager;
import com.senproj.luna.helpers.Settings;
import com.senproj.luna.hud.Hud;
import com.senproj.luna.map.GameMap;
import com.senproj.luna.map.blocks.BlockType;
import com.senproj.luna.map.factories.BlockFactory;
import com.senproj.luna.render.RenderManager;
import com.senproj.luna.sprites.Player;

public class PlayState extends GameState {
    private GameMap gamemap;
    private Player player;
    private Hud hud;

    public PlayState(GameStateManager gsm) {
        super(gsm);

        gamemap = new GameMap();
        player = new Player(gamemap);
        hud = new Hud(player);
        RenderManager.CAMERA.setToOrtho(false, Settings.SCREEN_WIDTH / 2.0f, Settings.SCREEN_HEIGHT / 2.0f);
    }

    @Override
    public void update(float dt) {
        player.update(dt);
        hud.update(dt);
        RenderManager.CAMERA.position.set(player.getPosX() * 16, player.getPosY() * 16, RenderManager.CAMERA.position.z);
        RenderManager.CAMERA.update();
        handleInput();
    }

    @Override
    public void render() {
        gamemap.render();
        player.render();
        RenderManager.render();

        hud.stage.draw();
    }

    @Override
    public void handleInput() {
        if (Gdx.input.isKeyPressed(Input.Keys.ESCAPE)) {
            Gdx.app.exit();
        }
        if (Gdx.input.justTouched()) {
            Vector3 tempVec = new Vector3(Gdx.input.getX(), Gdx.input.getY(), 0);
            RenderManager.CAMERA.unproject(tempVec);
            gamemap.getWorld()[CoordinateManager.pixelToWorld(tempVec.x)][CoordinateManager.pixelToWorld(tempVec.y)] =
                    BlockFactory.createBlock(CoordinateManager.pixelToWorld(tempVec.x), CoordinateManager.pixelToWorld(tempVec.y), BlockType.DIRT);
        }
    }

    @Override
    public void dispose() {
        gamemap.dispose();
        player.dispose();
    }
}
