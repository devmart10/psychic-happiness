package com.senproj.luna.hud;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.g2d.freetype.FreeTypeFontGenerator;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.utils.viewport.FitViewport;
import com.badlogic.gdx.utils.viewport.Viewport;
import com.senproj.luna.characters.Player;
import com.senproj.luna.helpers.Settings;

public class Hud {
    private Player player;

    //Scene2D.ui Stage and its own Viewport for HUD
    public Stage stage;
    private Viewport viewport;

    private Label lblScoreText;
    private Label lblScoreValue;
    private Label lblHealthText;
    private Label lblHealthValue;

    public Hud(SpriteBatch batch, Player player) {
        this.player = player;
        //setup the HUD viewport using a new camera seperate from our gamecam
        //define our stage using that viewport and our games spritebatch
        viewport = new FitViewport(Settings.SCREEN_WIDTH, Settings.SCREEN_HEIGHT, new OrthographicCamera());
        stage = new Stage(viewport, batch);

        Label.LabelStyle labelStyle = new Label.LabelStyle();
        labelStyle.font = getBitmapFont();

        lblScoreText = new Label("Score:", labelStyle);
        lblScoreValue = new Label("", labelStyle);
        lblHealthText = new Label("Health:", labelStyle);
        lblHealthValue = new Label("", labelStyle);

        //table for  organizing hud labels
        Table table = new Table();
//        table.setDebug(true);
        table.setFillParent(true);
        table.pad(5f);
        table.top().left();

        table.add(lblScoreText).left();
        table.add(lblScoreValue).expandX().left();
        table.row();
        table.add(lblHealthText).left();
        table.add(lblHealthValue).expandX().left();

        stage.addActor(table);
    }

    private BitmapFont getBitmapFont() {
        FreeTypeFontGenerator generator = new FreeTypeFontGenerator(Gdx.files.internal("fonts/emulogic/emulogic.ttf"));
        FreeTypeFontGenerator.FreeTypeFontParameter parameter = new FreeTypeFontGenerator.FreeTypeFontParameter();
        parameter.size = 30;
        parameter.borderWidth = 2;
        parameter.color = Color.WHITE;
        parameter.shadowOffsetX = 3;
        parameter.shadowOffsetY = 3;
        parameter.shadowColor = new Color(0, 0, 0, .5f);
        BitmapFont font = generator.generateFont(parameter); // font size 24 pixels
        generator.dispose();
        return font;
    }

    public void update(float dt) {
        lblScoreValue.setText(String.format("%06d", player.getScore()));
        lblHealthValue.setText(String.format("%03d", player.getHealth()));
    }

    public void draw(SpriteBatch batch) {

    }
}
