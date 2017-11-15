package com.senproj.luna.map.blocks;

import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.senproj.luna.render.RenderManager;
import com.senproj.luna.render.Renderable;

public abstract class OpaqueBlock extends Block implements Renderable {
    private TextureRegion tex;

    public OpaqueBlock(float posX, float posY, BlockType type, TextureRegion tex) {
        super(posX, posY, type);
        this.tex = tex;
    }

    @Override
    public float getPosX() {
        return super.getPosX();
    }

    @Override
    public float getPosY() {
        return super.getPosY();
    }

    @Override
    public TextureRegion getTex() {
        return tex;
    }

    @Override
    public void render() {
        RenderManager.queueRenderable(this);
    }
}
