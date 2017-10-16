package com.senproj.luna.map;

import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;
import com.senproj.luna.helpers.Settings;

public class GameMap {
    private Texture background;
    private Texture sheet;
    private Tree tree;
    private Tree tree2;

    public GameMap() {
        background = new Texture("game/map/background/map1.png");
        sheet = new Texture("game/map/terrain/terrain.png");

        tree = new Tree(sheet);
        tree.setPos(new Vector2(20*32, 15*32));

        tree2 = new Tree(sheet);
        tree2.setPos(new Vector2(25*32, 15*32));
    }

    public void draw(SpriteBatch batch) {
        batch.draw(background, 10*32, 0, 1024, 1024);
        tree.draw(batch);
        tree2.draw(batch);
    }

    public void dispose() {
        background.dispose();
        sheet.dispose();
    }
}
