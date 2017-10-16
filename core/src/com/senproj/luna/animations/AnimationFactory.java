package com.senproj.luna.animations;

import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.Animation;
import com.badlogic.gdx.graphics.g2d.TextureRegion;

public class AnimationFactory {

    public static Animation<TextureRegion> createAnimation(String ss_loc, int animNumCols, int totalNumCols, int colOffset,
                                                           int animNumRows, int totalNumRows, int rowOffset, float frameInterval) {
        Texture spritesheet = new Texture(ss_loc);

        return createAnimation(spritesheet, animNumCols, totalNumCols, colOffset, animNumRows, totalNumRows, rowOffset, frameInterval);
    }

    public static Animation<TextureRegion> createAnimation(Texture spritesheet, int animNumCols, int totalNumCols, int colOffset,
                                                           int animNumRows, int totalNumRows, int rowOffset, float frameInterval) {
        Animation<TextureRegion> retAnimation;

        TextureRegion[][] temp = TextureRegion.split(spritesheet,
                spritesheet.getWidth() / totalNumCols, spritesheet.getHeight() / totalNumRows);

        TextureRegion[] animFrames = new TextureRegion[animNumCols * animNumRows];
        for (int i = rowOffset, y = 0; i < totalNumRows && y < animNumRows; i++, y++) {
            for (int j = colOffset, x = 0; j < totalNumCols && x < animNumCols; j++, x++) {
                animFrames[y * animNumCols + x] = temp[i][j];
            }
        }

        retAnimation = new Animation<>(frameInterval, animFrames);

        return retAnimation;
    }
}
