package com.senproj.luna.render;

import com.badlogic.gdx.graphics.g2d.TextureRegion;

public interface Renderable {

    float getPosX();
    float getPosY();
    TextureRegion getTex();

    void render();
}
