package com.senproj.luna.map;

import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.maps.tiled.TiledMap;
import com.badlogic.gdx.maps.tiled.TmxMapLoader;
import com.badlogic.gdx.maps.tiled.renderers.OrthogonalTiledMapRenderer;

public class GameMap {
    private OrthographicCamera camera;

    private TiledMap map;
    private OrthogonalTiledMapRenderer renderer;

    public GameMap(OrthographicCamera camera) {
        map = new TmxMapLoader().load("game/map/terrain/my_map.tmx");
        renderer = new OrthogonalTiledMapRenderer(map);
        this.camera = camera;
    }

    public TiledMap getMap() {
        return map;
    }

    public void dispose() {

    }

    public void render() {
        renderer.setView(camera);
        renderer.render();
    }
}
