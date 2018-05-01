package com.senproj.luna.render;

import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;

public class RenderableTexture implements Renderable {

    private float posX, posY;
    private Texture tex;
    private TextureRegion textureRegion;

    public RenderableTexture(float posX, float posY, String texPath) {
        this.posX = posX;
        this.posY = posY;
        this.tex = new Texture(texPath);
        textureRegion = new TextureRegion(tex);
    }

    public RenderableTexture(float posX, float posY, Texture tex) {
        this.posX = posX;
        this.posY = posY;
        this.tex = tex;
        textureRegion = new TextureRegion(tex);
    }

    @Override
    public float getPosX() {
        return posX;
    }

    @Override
    public float getPosY() {
        return posY;
    }

    @Override
    public TextureRegion getTex() {
        return textureRegion;
    }

    @Override
    public void render() {
        RenderManager.queueRenderable(this);
    }

    public void dispose() {
        tex.dispose();
    }
}
