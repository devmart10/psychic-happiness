package com.senproj.luna.map;

import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.math.Vector2;

public class Tree {
    private TextureRegion top, trunk;
    private Vector2 pos;

    public Tree(Texture sheet) {
        top = new TextureRegion(sheet, 24*32, 15*32, 3*32, 3*32);
        trunk = new TextureRegion(sheet, 28*32, 19*32, 3*32, 3*32);

        pos = new Vector2(0, 0);
    }

    public void setPos(Vector2 pos) {
        this.pos = pos;
    }

    public void draw(SpriteBatch batch) {
        batch.draw(trunk, pos.x, pos.y - 2*32);
        batch.draw(top, pos.x, pos.y);
    }
}
