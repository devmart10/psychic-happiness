package com.senproj.luna.animations;

import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.Animation;
import com.badlogic.gdx.graphics.g2d.TextureRegion;

public class AnimationFactory {

    public static Animation<TextureRegion> createAnimation(String ss_loc, int ss_width, int ss_height, float frameInterval) {
        Texture spritesheet = new Texture(ss_loc);

        return createAnimation(spritesheet, ss_width, ss_height, frameInterval);
    }

    public static Animation<TextureRegion> createAnimation(Texture spritesheet, int ss_width, int ss_height, float frameInterval) {
        Animation<TextureRegion> retAnimation;

        TextureRegion[][] temp = TextureRegion.split(spritesheet,
                spritesheet.getWidth() / ss_width, spritesheet.getHeight() / ss_height);

        TextureRegion[] animFrames = new TextureRegion[ss_width * ss_height];
        for (int i = 0; i < ss_height; i++) {
            for (int j = 0; j < ss_width; j++) {
                animFrames[i * ss_width + j] = temp[i][j];
            }
        }

        retAnimation = new Animation<>(frameInterval, animFrames);

        return retAnimation;
    }
}
