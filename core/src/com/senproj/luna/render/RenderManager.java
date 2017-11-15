package com.senproj.luna.render;

import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.senproj.luna.collisions.CollisionBox;
import com.senproj.luna.helpers.CoordinateManager;
import com.senproj.luna.helpers.Settings;

import java.util.ArrayList;

public class RenderManager {
    private static String blockTexturePath = "game/map/terrain/tileset/block_tileset.png";

    public static OrthographicCamera CAMERA = new OrthographicCamera();

    private static ShapeRenderer shapeRenderer = new ShapeRenderer();

    private static Texture backgroundTexture = new Texture("game/map/background/temp_background.png");
    public static Texture BLOCK_TEXTURES = new Texture(blockTexturePath);
    public static SpriteBatch spriteBatch = new SpriteBatch();
    private static ArrayList<Renderable> toRender = new ArrayList<>();
    private static ArrayList<CollisionBox> drawBoxesToRender = new ArrayList<>();

    public static void render() {
        spriteBatch.setProjectionMatrix(CAMERA.combined);

        spriteBatch.begin();
        spriteBatch.draw(backgroundTexture, 0, 0);
        for (Renderable renderable : toRender) {
            TextureRegion tex = renderable.getTex();
            spriteBatch.draw(tex, CoordinateManager.worldToPixel(renderable.getPosX()), CoordinateManager.worldToPixel(renderable.getPosY()));
        }
        spriteBatch.end();

        if (Settings.DEBUG) {
            shapeRenderer.setProjectionMatrix(CAMERA.combined);
            shapeRenderer.begin(ShapeRenderer.ShapeType.Line);
            shapeRenderer.setColor(Color.RED);
            for (CollisionBox box : drawBoxesToRender) {
                shapeRenderer.rect(CoordinateManager.worldToPixel(box.getPosX()),
                        CoordinateManager.worldToPixel(box.getPosY()),
                        CoordinateManager.worldToPixel(box.getWidth()),
                        CoordinateManager.worldToPixel(box.getHeight()));
            }
            shapeRenderer.end();

            drawBoxesToRender.clear();
            toRender.clear();
        }
    }

    public static void queueRenderable(Renderable renderable) {
        toRender.add(renderable);
    }
    public static void queueDrawBox(CollisionBox box){drawBoxesToRender.add(box);}

    public static void dispose() {
        spriteBatch.dispose();
        backgroundTexture.dispose();
        BLOCK_TEXTURES.dispose();
    }
}
