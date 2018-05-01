package com.senproj.luna.gui;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.senproj.luna.helpers.Settings;

public class GuiButtonFactory {

    public static GuiButton createButton(GuiButtonConstants buttonType) {
        GuiButton returnButton = null;
        Texture tex;

        switch (buttonType) {
            case NEW_GAME_BUTTON:
                tex = new Texture("menu/button/new_game.png");
                returnButton = new GuiButton((int)(Settings.SCREEN_WIDTH / 2.0f),
                        (int)(Settings.SCREEN_HEIGHT / 2.0f), buttonType, tex);
                break;
            case EXIT_GAME_BUTTON:
                tex = new Texture("menu/button/exit_game.png");
                returnButton = new GuiButton((int)(Settings.SCREEN_WIDTH / 2.0f),
                        (int)(Settings.SCREEN_HEIGHT / 2.5), buttonType, tex);
                break;
            default:
                Gdx.app.error("GUI", String.format("Tried to initialize unknown button type %s", buttonType.toString()));
                break;
        }

        return returnButton;
    }
}
