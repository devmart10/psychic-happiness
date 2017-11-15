package com.senproj.luna.map.factories;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.senproj.luna.map.blocks.*;
import com.senproj.luna.render.RenderManager;

public class BlockFactory {

    public static Block createBlock(int posX, int posY, BlockType type) {
        Block retBlock;
        TextureRegion blockTexture;

        switch(type) {
            case DIRT:
                blockTexture = new TextureRegion(RenderManager.BLOCK_TEXTURES, 0, 0, 16, 16);
                retBlock = new SolidBlock(posX, posY, type, blockTexture);
                break;
            case SKY:
                retBlock = new TransparentBlock(posX, posY, type);
                break;
            default:
                Gdx.app.debug("DEBUG", String.format("Unhandled block type %s. Please add a case for this block type in BlockFactory.", type));
                retBlock = null;
        }

        return retBlock;
    }
}
