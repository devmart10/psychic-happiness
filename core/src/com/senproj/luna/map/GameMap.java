package com.senproj.luna.map;

import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.maps.tiled.TiledMap;
import com.badlogic.gdx.maps.tiled.TmxMapLoader;
import com.badlogic.gdx.maps.tiled.renderers.OrthogonalTiledMapRenderer;
import com.badlogic.gdx.math.Vector2;

public class GameMap {
    private OrthographicCamera camera;
    private Texture background;
    private Texture sheet;
    private Tree tree;
    private Tree tree2;

    private TiledMap map;
    private OrthogonalTiledMapRenderer renderer;

    public GameMap(OrthographicCamera camera) {
        background = new Texture("game/map/background/map1.png");
        sheet = new Texture("game/map/terrain/terrain.png");

        map = new TmxMapLoader().load("game/map/terrain/my_map.tmx");
        renderer = new OrthogonalTiledMapRenderer(map);
        this.camera = camera;

        tree = new Tree(sheet);
        tree.setPos(new Vector2(20 * 32, 15 * 32));

        tree2 = new Tree(sheet);
        tree2.setPos(new Vector2(25 * 32, 15 * 32));
    }

    // don't need anymore, but leaving it here in case we want to go back
    public void draw(SpriteBatch batch) {
        batch.draw(background, 10*32, 0, 1024, 1024);
        tree.draw(batch);
        tree2.draw(batch);
    }

    public void dispose() {
        background.dispose();
        sheet.dispose();
    }

    public void render() {
        renderer.setView(camera);
        renderer.render();
    }
}
